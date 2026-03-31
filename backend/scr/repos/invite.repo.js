import { getDB } from "../config/db.js";

function normalizeVnPhone(phone) {
  let digits = String(phone || "").replace(/\D/g, "");
  if (!digits) return "";
  if (digits.startsWith("84")) {
    digits = "0" + digits.slice(2);
  }
  return digits;
}

/* =========================
   GỬI LỜI MỜI
========================= */
export async function sendInvite(fromId, toId) {
  const db = getDB();

  if (fromId === toId) throw new Error("Không thể mời chính mình");

  const { data: existing } = await db
    .from("loimoi")
    .select("loimoi_id")
    .eq("nguoimoi_id", fromId)
    .eq("nguoiduocmoi_id", toId)
    .eq("trangthailoimoi_id", "0")
    .maybeSingle();

  if (existing) throw new Error("Lời mời đã tồn tại");

  const { error } = await db.from("loimoi").insert({
    loimoi_id: "LM" + Date.now().toString().slice(-10),
    ngaygui: new Date().toISOString(),
    trangthailoimoi_id: "0",
    nguoimoi_id: fromId,
    nguoiduocmoi_id: toId,
  });

  if (error) throw error;
}

/* =========================
   ACCEPT
========================= */
export async function acceptInvite(loiMoiId) {
  const db = getDB();

  // update
  const { data: updated, error: errUp } = await db
    .from("loimoi")
    .update({
      trangthailoimoi_id: "1",
      ngayphanhoi: new Date().toISOString(),
    })
    .eq("loimoi_id", loiMoiId)
    .eq("trangthailoimoi_id", "0")
    .select()
    .maybeSingle();

  if (errUp) throw errUp;
  if (!updated) throw new Error("Lời mời không hợp lệ");

  // insert quan hệ
  const { data: relation, error: errRel } = await db
    .from("quanhegiamho")
    .insert({
      quanhegiamho_id: "QH" + Date.now().toString().slice(-10),
      loimoi_id: loiMoiId,
      nguoigiamho_id: updated.nguoiduocmoi_id,   
      nguoiduocgiamho_id: updated.nguoimoi_id,   
      ngaybatdau: new Date().toISOString(),
      daxoa: false,
    })
    .select(`
      quanhegiamho_id,
      ngaybatdau,
      nguoidung:nguoigiamho_id (
        tennd,
        avatarurl
      )
    `)
    .single();

  if (errRel) throw errRel;

  return relation;
}
/* =========================
   TỪ CHỐI
========================= */
export async function rejectInvite(loiMoiId) {
  const db = getDB();

  const { data } = await db
    .from("loimoi")
    .update({
      trangthailoimoi_id: "2",
      ngayphanhoi: new Date().toISOString(),
    })
    .eq("loimoi_id", loiMoiId)
    .eq("trangthailoimoi_id", "0")
    .select();

  if (!data || data.length === 0) {
    throw new Error("Lời mời không hợp lệ");
  }
}

/* =========================
   DANH SÁCH LỜI MỜI ĐẾN
========================= */
export async function getInvites(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("loimoi")
    .select(`
      loimoi_id,
      ngaygui,
      nguoidung:nguoimoi_id (
        nguoidung_id,
        tennd,
        avatarurl,
        taikhoan (
          sodienthoai
        )
      )
    `)
    .eq("nguoiduocmoi_id", userId)
    .eq("trangthailoimoi_id", "0")
    .order("ngaygui", { ascending: false });

  if (error) throw error;

  return data;
}
/* =========================
   GỬI LỜI MỜI BẰNG SĐT
========================= */
export async function sendInviteByPhone(fromId, phone) {
  const db = getDB();
  const normalizedPhone = normalizeVnPhone(phone);
  if (!normalizedPhone) throw new Error("Thiếu số điện thoại");

  const { data: user } = await db
    .from("taikhoan")
    .select("nguoidung_id")
    .eq("sodienthoai", normalizedPhone)
    .maybeSingle();

  if (!user) throw new Error("Số điện thoại chưa đăng ký");

  return sendInvite(fromId, user.nguoidung_id);
}
export async function findUserByPhone(phone, currentUserId) {
  const db = getDB();
  const normalizedPhone = normalizeVnPhone(phone);
  if (!normalizedPhone) return [];

  const { data, error } = await db
    .from("taikhoan")
    .select(`
      sodienthoai,
      nguoidung (
        nguoidung_id,
        tennd,
        avatarurl
      )
    `)
    .ilike("sodienthoai", `${normalizedPhone}%`);

  if (error) throw error;

  const users = (data || [])
    .map(u => ({
      ...u.nguoidung,
      sodienthoai: u.sodienthoai,
    }))
    .filter(u => u?.nguoidung_id && u.nguoidung_id !== currentUserId);

  if (users.length === 0) return [];

  const ids = users.map(u => u.nguoidung_id);

  const { data: invites, error: inviteErr } = await db
    .from("loimoi")
    .select("loimoi_id, nguoimoi_id, nguoiduocmoi_id, trangthailoimoi_id")
    .or(
      `and(nguoimoi_id.eq.${currentUserId},nguoiduocmoi_id.in.(${ids.join(",")})),and(nguoiduocmoi_id.eq.${currentUserId},nguoimoi_id.in.(${ids.join(",")}))`
    );
  if (inviteErr) throw inviteErr;

  const { data: relations, error: relErr } = await db
    .from("quanhegiamho")
    .select("nguoigiamho_id, nguoiduocgiamho_id, daxoa")
    .or(
      `and(nguoigiamho_id.eq.${currentUserId},nguoiduocgiamho_id.in.(${ids.join(",")})),and(nguoiduocgiamho_id.eq.${currentUserId},nguoigiamho_id.in.(${ids.join(",")}))`
    )
    .eq("daxoa", false);
  if (relErr) throw relErr;

  return users.map(u => {
    const related = (relations || []).some(r => {
      return (
        (r.nguoigiamho_id === currentUserId &&
          r.nguoiduocgiamho_id === u.nguoidung_id) ||
        (r.nguoiduocgiamho_id === currentUserId &&
          r.nguoigiamho_id === u.nguoidung_id)
      );
    });

    if (related) {
      return {
        ...u,
        inviteStatus: "related",
      };
    }

    const outgoingPending = (invites || []).find(i => {
      return (
        i.nguoimoi_id === currentUserId &&
        i.nguoiduocmoi_id === u.nguoidung_id &&
        i.trangthailoimoi_id === "0"
      );
    });
    if (outgoingPending) {
      return {
        ...u,
        inviteStatus: "pending",
        loimoi_id: outgoingPending.loimoi_id,
      };
    }

    const incomingPending = (invites || []).find(i => {
      return (
        i.nguoiduocmoi_id === currentUserId &&
        i.nguoimoi_id === u.nguoidung_id &&
        i.trangthailoimoi_id === "0"
      );
    });
    if (incomingPending) {
      return {
        ...u,
        inviteStatus: "incoming",
        loimoi_id: incomingPending.loimoi_id,
      };
    }

    return {
      ...u,
      inviteStatus: "none",
    };
  });
}
export async function cancelInvite(loiMoiId, fromId) {
  const db = getDB();

  const { data } = await db
    .from("loimoi")
    .update({ trangthailoimoi_id: "3" })
    .eq("loimoi_id", loiMoiId)
    .eq("nguoimoi_id", fromId)
    .eq("trangthailoimoi_id", "0")
    .select();

  if (!data || data.length === 0) {
    throw new Error("Không thể hủy lời mời");
  }
}
