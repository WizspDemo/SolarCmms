import React from 'react';

interface StatusBadgeProps {
  criticalDefects: number;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ criticalDefects }) => {
  let bgColor = 'bg-green-100';
  let textColor = 'text-green-800';
  let label = 'Healthy';
  let dotColor = 'bg-green-500';

  if (criticalDefects >= 3) {
    bgColor = 'bg-red-100';
    textColor = 'text-red-800';
    label = 'Critical';
    dotColor = 'bg-red-500';
  } else if (criticalDefects > 0) {
    bgColor = 'bg-yellow-100';
    textColor = 'text-yellow-800';
    label = 'Warning';
    dotColor = 'bg-yellow-500';
  }

  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${bgColor} ${textColor}`}>
      <span className={`w-1.5 h-1.5 mr-1.5 rounded-full ${dotColor}`}></span>
      {label}
    </span>
  );
};