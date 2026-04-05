// src/utils/time.js
// ALWAYS UTC BASE

/**
 * Lấy giờ hiện tại của Việt Nam (0-23) dựa trên giờ UTC.
 * Công thức: (UTC Hour + 7) % 24
 */
export const getCurrentVNHour = () => {
  const now = new Date();
  return (now.getUTCHours() + 7) % 24;
};

/**
 * Xác định thời điểm bắt đầu ngày của Việt Nam (00:00:00 VN) dưới dạng chuỗi ISO UTC.
 * 00:00:00 VN hôm nay = 17:00:00 UTC ngày hôm trước.
 */
export const getVNStartOfDayUTC = (date = new Date()) => {
  const d = new Date(date);
  // Nếu giờ UTC >= 17h, nghĩa là ở VN đã sang ngày mới (UTC+7).
  // Ví dụ: 17:00 UTC ngày 20/05 -> 00:00 VN ngày 21/05.
  // Chúng ta muốn 00:00 VN của *ngày tương ứng* với `date`.
  
  const utc = new Date(Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate()
  ));

  // 00:00 VN = 17:00 UTC ngày hôm TRƯỚC
  utc.setUTCHours(17, 0, 0, 0);
  
  // Nếu date hiện tại nhỏ hơn 17:00 UTC, thì 00:00 VN của ngày đó bắt đầu từ 17:00 UTC ngày hôm qua.
  if (d.getUTCHours() < 17) {
    utc.setUTCDate(utc.getUTCDate() - 1);
  }

  return utc.toISOString();
};

/**
 * Xác định thời điểm kết thúc ngày của Việt Nam (23:59:59 VN) dưới dạng chuỗi ISO UTC.
 */
export const getVNEndOfDayUTC = (date = new Date()) => {
  const start = new Date(getVNStartOfDayUTC(date));
  // Kết thúc ngày = Bắt đầu ngày + 23h 59m 59s 999ms
  start.setUTCHours(start.getUTCHours() + 23);
  start.setUTCMinutes(59, 59, 999);
  return start.toISOString();
};

/**
 * Lấy chuỗi ngày YYYY-MM-DD theo giờ Việt Nam.
 */
export const getVNDateString = (date = new Date()) => {
  const d = new Date(date);
  d.setUTCHours(d.getUTCHours() + 7);
  return d.toISOString().split('T')[0];
};
