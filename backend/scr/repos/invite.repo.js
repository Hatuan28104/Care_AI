import sql from "mssql";
import { getDB } from "../../db.js";

/* =========================
   GỬI LỜI MỜI
========================= */
export async function sendInvite(fromId, toId) {
  const db = await getDB();

  if (fromId === toId) throw new Error("Không thể mời chính mình");

  const check = await db.request()
    .input("f", sql.Char(12), fromId)
    .input("t", sql.Char(12), toId)
    .query(`
      SELECT 1 FROM LoiMoi
      WHERE NguoiMoi_ID = @f
        AND NguoiDuocMoi_ID = @t
        AND TrangThaiLoiMoi = 0
    `);

  if (check.recordset.length) {
    throw new Error("Lời mời đã tồn tại");
  }

await db.request()
  .input("from", sql.Char(12), fromId)
  .input("to", sql.Char(12), toId)
  .query(`
    INSERT INTO LoiMoi (
      LoiMoi_ID, NgayGui, TrangThaiLoiMoi,
      NguoiMoi_ID, NguoiDuocMoi_ID
    )
    VALUES (
      'LM' + RIGHT(NEWID(), 10),
      GETDATE(), 0,
      @from, @to
    )
  `);

}

/* =========================
   ACCEPT
========================= */
export async function acceptInvite(loiMoiId) {
  const db = await getDB();
  const tx = new sql.Transaction(db);
  await tx.begin();

  try {
    const up = await tx.request().query(`
      UPDATE LoiMoi
      SET TrangThaiLoiMoi = 1,
          NgayPhanHoi = GETDATE()
      WHERE LoiMoi_ID = '${loiMoiId}'
        AND TrangThaiLoiMoi = 0
    `);

    if (up.rowsAffected[0] === 0) {
      throw new Error("Lời mời không hợp lệ");
    }

    await tx.request().query(`
      INSERT INTO QuanHeGiamHo (
        QuanHeGiamHo_ID, LoiMoi_ID,
        NguoiDuocGiamHo_ID, NguoiGiamHo_ID,
        NgayBatDau, DaXoa
      )
      SELECT
        'QH' + RIGHT(NEWID(), 10),
        LoiMoi_ID,
        NguoiDuocMoi_ID,
        NguoiMoi_ID,
        GETDATE(), 0
      FROM LoiMoi
      WHERE LoiMoi_ID = '${loiMoiId}'
    `);

    await tx.commit();
  } catch (e) {
    await tx.rollback();
    throw e;
  }
}

/* =========================
   TỪ CHỐI
========================= */
export async function rejectInvite(loiMoiId) {
  const db = await getDB();

  const rs = await db.request().query(`
    UPDATE LoiMoi
    SET TrangThaiLoiMoi = 2,
        NgayPhanHoi = GETDATE()
    WHERE LoiMoi_ID = '${loiMoiId}'
      AND TrangThaiLoiMoi = 0
  `);

  if (rs.rowsAffected[0] === 0) {
    throw new Error("Lời mời không hợp lệ");
  }
}

/* =========================
   DANH SÁCH LỜI MỜI ĐẾN
========================= */
export async function getInvites(userId) {
  const db = await getDB();

  const rs = await db.request()
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT
        LM.LoiMoi_ID,
        LM.NgayGui,
        ND.NguoiDung_ID AS NguoiMoi_ID,
        ND.AvatarUrl,
        ND.TenND,
        TK.SoDienThoai
      FROM LoiMoi LM
      JOIN NguoiDung ND
        ON ND.NguoiDung_ID = LM.NguoiMoi_ID
      JOIN TaiKhoan TK
        ON TK.NguoiDung_ID = ND.NguoiDung_ID
      WHERE LM.NguoiDuocMoi_ID = @uid
        AND LM.TrangThaiLoiMoi = 0
      ORDER BY LM.NgayGui DESC
    `);

  return rs.recordset;
}

/* =========================
   GỬI LỜI MỜI BẰNG SĐT
========================= */
export async function sendInviteByPhone(fromId, phone) {
  const db = await getDB();

  if (!fromId) throw new Error("Thiếu người gửi");
  if (!phone) throw new Error("Thiếu số điện thoại");

  // 1. tìm user theo SĐT
  const rs = await db.request()
    .input("phone", sql.NVarChar(15), phone)
    .query(`
      SELECT NguoiDung_ID
      FROM TaiKhoan
      WHERE SoDienThoai = @phone
    `);

  if (rs.recordset.length === 0) {
    throw new Error("Số điện thoại chưa đăng ký");
  }

  const toUserId = rs.recordset[0].NguoiDung_ID;

  // 2. gọi lại logic cũ
  return sendInvite(fromId, toUserId);
}
export async function findUserByPhone(phone, currentUserId) {
  const db = await getDB();

  const rs = await db.request()
    .input("phone", sql.NVarChar(15), phone)
    .input("me", sql.Char(12), currentUserId)
    .query(`
      SELECT 
        ND.NguoiDung_ID,
        ND.TenND,
        ND.AvatarUrl,
        TK.SoDienThoai,
        LM.LoiMoi_ID,
        LM.TrangThaiLoiMoi
      FROM TaiKhoan TK
      JOIN NguoiDung ND 
        ON TK.NguoiDung_ID = ND.NguoiDung_ID
      LEFT JOIN LoiMoi LM
        ON LM.NguoiMoi_ID = @me
       AND LM.NguoiDuocMoi_ID = ND.NguoiDung_ID
       AND LM.TrangThaiLoiMoi = 0
      WHERE TK.SoDienThoai LIKE @phone + '%'
    `);

  return rs.recordset.map(u => ({
    ...u,
    inviteStatus: u.TrangThaiLoiMoi === 0 ? "pending" : "none"
  }));
}
export async function cancelInvite(loiMoiId, fromId) {
  const db = await getDB();

  const rs = await db.request()
    .input("id", sql.Char(12), loiMoiId)
    .input("from", sql.Char(12), fromId)
    .query(`
      UPDATE LoiMoi
      SET TrangThaiLoiMoi = 3
      WHERE LoiMoi_ID = @id
        AND NguoiMoi_ID = @from
        AND TrangThaiLoiMoi = 0
    `);

  if (rs.rowsAffected[0] === 0) {
    throw new Error("Không thể hủy lời mời");
  }
}

