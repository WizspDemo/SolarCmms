/**
 * Weather API Service - Open-Meteo (free, no API key)
 * Provides: ambient temp, GHI (irradiance), wind, cloud cover, 4-hour forecast
 * Module temp & soiling risk are derived from API data.
 * @see https://open-meteo.com/en/docs
 */
(function (global) {
    'use strict';

    const OPEN_METEO_BASE = 'https://api.open-meteo.com/v1/forecast';
    const DEFAULT_LAT = 24.456;
    const DEFAULT_LON = 32.739;

    function degreesToCompass(deg) {
        const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
        const idx = Math.round((deg % 360) / 22.5);
        return dirs[idx % 16];
    }

    function wmoCodeToCondition(code) {
        if (code === 0) return 'Sunny';
        if (code >= 1 && code <= 3) return 'PartlyCloudyDay';
        if (code >= 45 && code <= 48) return 'Cloudy';
        if (code >= 51 && code <= 67) return 'Rain';
        if (code >= 71 && code <= 77) return 'Snow';
        if (code >= 80 && code <= 82) return 'Rain';
        if (code >= 85 && code <= 86) return 'Snow';
        if (code >= 95 && code <= 99) return 'Rain';
        return code <= 3 ? 'PartlyCloudyDay' : 'Cloudy';
    }

    function wmoCodeToFluentIcon(code) {
        return wmoCodeToCondition(code);
    }

    function estimateModuleTemp(ambientTemp, ghi) {
        if (ghi <= 0) return ambientTemp;
        const delta = (ghi / 1000) * 28;
        return Math.round((ambientTemp + delta) * 10) / 10;
    }

    function deriveSoilingRisk(windSpeedKmh, cloudCover, weatherCode) {
        if (weatherCode >= 95 || (windSpeedKmh > 40 && cloudCover < 30)) return 'High';
        if (windSpeedKmh > 15 || cloudCover > 70) return 'Medium';
        return 'Low';
    }

    function cloudCoverToDescription(pct) {
        if (pct <= 10) return 'Clear';
        if (pct <= 30) return 'Scattered';
        if (pct <= 70) return 'Partly Cloudy';
        return 'Overcast';
    }

    function formatHour(isoStr) {
        try {
            const d = new Date(isoStr);
            return d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
        } catch (_) {
            return isoStr ? isoStr.slice(11, 16) : '--:--';
        }
    }

    /**
     * Fetch weather from Open-Meteo and normalize to dashboard format.
     * @param {number} lat - Latitude
     * @param {number} lon - Longitude
     * @returns {Promise<{current: object, hourly: array}>}
     */
    async function fetchWeather(lat, lon) {
        const latitude = typeof lat === 'number' && !isNaN(lat) ? lat : DEFAULT_LAT;
        const longitude = typeof lon === 'number' && !isNaN(lon) ? lon : DEFAULT_LON;

        const params = new URLSearchParams({
            latitude: String(latitude),
            longitude: String(longitude),
            current: 'temperature_2m,cloud_cover,wind_speed_10m,wind_direction_10m,shortwave_radiation',
            hourly: 'temperature_2m,shortwave_radiation,weather_code,cloud_cover',
            wind_speed_unit: 'kmh',
            timezone: 'auto',
            forecast_days: '1'
        });

        const url = OPEN_METEO_BASE + '?' + params.toString();
        const res = await fetch(url);
        if (!res.ok) throw new Error('Weather API error: ' + res.status);
        const data = await res.json();

        const cur = data.current || {};
        const hourly = data.hourly || {};
        const times = hourly.time || [];
        const temps = hourly.temperature_2m || [];
        const ghiArr = hourly.shortwave_radiation || [];
        const codes = hourly.weather_code || [];
        const clouds = hourly.cloud_cover || [];

        const now = new Date();
        let currentGhi = cur.shortwave_radiation;
        if (currentGhi == null && ghiArr.length > 0) {
            const hourIdx = Math.min(Math.floor(now.getHours()), times.length - 1);
            currentGhi = ghiArr[hourIdx];
        }
        currentGhi = currentGhi != null ? Math.round(currentGhi) : 0;

        const ambientTemp = cur.temperature_2m != null ? Math.round(cur.temperature_2m * 10) / 10 : (temps[0] != null ? temps[0] : 0);
        const windSpeed = cur.wind_speed_10m != null ? Math.round(cur.wind_speed_10m * 10) / 10 : 0;
        const windDir = cur.wind_direction_10m != null ? degreesToCompass(cur.wind_direction_10m) : 'N';
        const cloudCover = cur.cloud_cover != null ? Math.round(cur.cloud_cover) : (clouds[0] != null ? clouds[0] : 0);
        const weatherCode = codes[Math.min(now.getHours(), codes.length - 1)] || 0;

        const moduleTemp = estimateModuleTemp(ambientTemp, currentGhi);
        const soilingRisk = deriveSoilingRisk(windSpeed, cloudCover, weatherCode);
        const condition = wmoCodeToCondition(weatherCode);

        const current = {
            ghi: currentGhi,
            moduleTemp,
            ambientTemp,
            windSpeed,
            windDirection: windDir,
            cloudCover,
            cloudCoverDesc: cloudCoverToDescription(cloudCover),
            soilingRisk,
            condition
        };

        const startHour = now.getHours();
        const hourlyForecast = [];
        for (let i = 0; i < 4; i++) {
            const idx = startHour + i;
            if (idx >= times.length) break;
            hourlyForecast.push({
                time: formatHour(times[idx]),
                icon: wmoCodeToFluentIcon(codes[idx] || 0),
                temp: Math.round(temps[idx] != null ? temps[idx] : 0),
                ghi: Math.round(ghiArr[idx] != null ? ghiArr[idx] : 0),
                precip: 0
            });
        }

        return { current, hourly: hourlyForecast };
    }

    global.WeatherApiService = {
        fetchWeather,
        DEFAULT_LAT,
        DEFAULT_LON
    };
})(typeof window !== 'undefined' ? window : globalThis);
