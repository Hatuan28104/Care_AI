export const getCurrentVNHour = () => {
  const now = new Date();
  return (now.getUTCHours() + 7) % 24;
};

export const getVNStartOfDayUTC = (date = new Date()) => {
  const d = new Date(date);

  const utc = new Date(Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate()
  ));

  utc.setUTCHours(17, 0, 0, 0);
  
  if (d.getUTCHours() < 17) {
    utc.setUTCDate(utc.getUTCDate() - 1);
  }

  return utc.toISOString();
};

export const getVNEndOfDayUTC = (date = new Date()) => {
  const start = new Date(getVNStartOfDayUTC(date));
  start.setUTCHours(start.getUTCHours() + 23);
  start.setUTCMinutes(59, 59, 999);
  return start.toISOString();
};

export const getVNDateString = (date = new Date()) => {
  const d = new Date(date);
  d.setUTCHours(d.getUTCHours() + 7);
  return d.toISOString().split('T')[0];
};
