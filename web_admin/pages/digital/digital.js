const DIGITAL_PAGE_SIZE = 10;
const API_BASE = 'https://careai-production.up.railway.app';
const API = `${API_BASE}/api/digital-human`;

let digitalPage = 1;
let characters = [];
let filteredChars = [];
let isSearching = false;

function t(key) {
    return window.I18n?.t(key) || key;
}

function tf(key, params = {}) {
    if (window.I18n?.format) return window.I18n.format(key, params);
    return key.replace(/\{(\w+)\}/g, (_, token) => params[token] ?? '');
}

function getCurrentDigitalPage() {
    const byData = document.body?.dataset?.page;
    if (byData) return byData;

    const path = window.location.pathname.toLowerCase();
    if (path.includes('digital-view')) return 'digital-view';
    if (path.includes('digital-edit')) return 'digital-edit';
    if (path.includes('digital-add')) return 'digital-add';
    if (path.includes('digital')) return 'digital';
    return '';
}

function toAbsoluteImageUrl(path) {
    if (!path) return 'https://cdn-icons-png.flaticon.com/512/149/149071.png';
    if (/^https?:\/\//i.test(path)) return path;
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `${API_BASE}${cleanPath}`;
}

function toStoredImagePath(urlOrPath) {
    if (!urlOrPath) return '';
    if (/^https?:\/\//i.test(urlOrPath)) {
        return urlOrPath.replace(`${API_BASE}/`, '').replace(`${API_BASE}`, '');
    }
    return urlOrPath.startsWith('/') ? urlOrPath.slice(1) : urlOrPath;
}

function showToastMessage(message) {
    if (window.UI?.showToast) {
        UI.showToast(message);
        return;
    }
    alert(message);
}

function confirmModal({ title, message, type = 'success', onConfirm }) {
    if (window.UI?.showModal) {
        UI.showModal({
            type,
            title,
            message,
            confirmText: type === 'danger' ? t('Xóa') : t('Xác nhận'),
            cancelText: t('Hủy bỏ'),
            onConfirm
        });
        return;
    }

    const ok = window.confirm(message || title || t('Xác nhận thao tác?'));
    if (ok && typeof onConfirm === 'function') onConfirm();
}

async function fetchDigitalCharacters() {
    try {
        const res = await fetch(API);
        const result = await res.json();

        const mapped = (result?.data || []).map((d) => {
            const genderValue = d.gioitinh === 1 || d.gioitinh === true || d.gioitinh === '1';
            const gender = genderValue ? t('Nam') : t('Nữ');
            return {
                id: d.digitalhuman_id || '',
                name: d.tendigitalhuman || '',
                job: d.nghenghiep?.tennghenghiep || d.nghenghiep_id || '-',
                gender,
                genderClass: genderValue ? 'badge--info' : 'badge--pink',
                genderRaw: d.gioitinh,
                img: toAbsoluteImageUrl(d.imageurl)
            };
        });

        characters = mapped;
        filteredChars = [...characters];
        digitalPage = 1;
        renderDigitalTable();
    } catch (error) {
        console.error(error);
        characters = [];
        filteredChars = [];
        renderDigitalTable();
    }
}

async function loadDigitalDetail(id) {
    if (!id) return;

    try {
        const res = await fetch(`${API}/${id}`);
        const json = await res.json();
        const d = json?.data;
        if (!d) return;

        const title = document.getElementById('digitalTitle');
        const digitalId = document.getElementById('digitalId');
        const digitalIdDetail = document.getElementById('digitalIdDetail');
        const digitalName = document.getElementById('digitalName');
        const digitalGender = document.getElementById('digitalGender');
        const digitalJob = document.getElementById('digitalJob');
        const digitalAppearance = document.getElementById('digitalAppearance');
        const digitalPrompt = document.getElementById('digitalPrompt');
        const digitalAvatar = document.getElementById('digitalAvatar');
        const btnEditFromView = document.getElementById('btnEditFromView');
        const btnDeleteFromView = document.getElementById('btnDeleteFromView');

        if (title) title.innerText = d.tendigitalhuman || '';
        if (digitalId) digitalId.innerText = d.digitalhuman_id || '';
        if (digitalIdDetail) digitalIdDetail.innerText = d.digitalhuman_id || '';
        if (digitalName) digitalName.innerText = d.tendigitalhuman || '';
        if (digitalGender) {
            const genderValue = d.gioitinh === 1 || d.gioitinh === true || d.gioitinh === '1';
            digitalGender.innerText = genderValue ? t('Nam') : t('Nữ');
        }
        if (digitalJob) digitalJob.innerText = d.nghenghiep?.tennghenghiep || d.nghenghiep_id || '-';
        if (digitalAppearance) digitalAppearance.innerText = d.ngoaihinh || '-';
        if (digitalPrompt) digitalPrompt.innerText = d.systemprompt || d.mota || '-';
        if (digitalAvatar) digitalAvatar.src = toAbsoluteImageUrl(d.imageurl);

        btnEditFromView?.addEventListener('click', () => {
            window.location.href = `digital-edit.html?id=${d.digitalhuman_id}`;
        });

        btnDeleteFromView?.addEventListener('click', () => {
            confirmDeleteChar(d.digitalhuman_id);
        });
    } catch (error) {
        console.error(error);
    }
}

async function preloadDigitalForm(id) {
    if (!id) return;

    try {
        const res = await fetch(`${API}/${id}`);
        const json = await res.json();
        const d = json?.data;
        if (!d) return;

        const digitalId = document.getElementById('digitalId');
        const digitalName = document.getElementById('digitalName');
        const gender = document.getElementById('gender');
        const jobId = document.getElementById('jobId');
        const appearance = document.getElementById('appearance');
        const systemPrompt = document.getElementById('systemPrompt');
        const avatarPreview = document.getElementById('avatarPreview');

        if (digitalId) {
            digitalId.value = d.digitalhuman_id || '';
            digitalId.disabled = true;
        }
        if (digitalName) digitalName.value = d.tendigitalhuman || '';
        if (gender) {
            const val = String(d.gioitinh);
            gender.value = val;

            const genderSwitcher = document.getElementById('genderSwitcher');
            if (genderSwitcher) {
                genderSwitcher.querySelectorAll('.gender-opt').forEach((opt) => {
                    opt.classList.toggle('active', opt.dataset.value === val);
                });
            }
        }
        if (jobId) jobId.value = (d.nghenghiep_id || '').trim();
        if (appearance) appearance.value = d.ngoaihinh || '';
        if (systemPrompt) systemPrompt.value = d.systemprompt || d.mota || '';

        if (d.imageurl && avatarPreview) {
            avatarPreview.src = toAbsoluteImageUrl(d.imageurl);
            avatarPreview.classList.remove('hidden');
        }
    } catch (error) {
        console.error(error);
    }
}

function renderDigitalTable() {
    const tbody = document.querySelector('.premium-table tbody');
    const emptyState = document.getElementById('empty-state');
    const paginationWrapper = document.querySelector('.pagination-row');
    if (!tbody) return;

    const start = (digitalPage - 1) * DIGITAL_PAGE_SIZE;
    const pageData = filteredChars.slice(start, start + DIGITAL_PAGE_SIZE);

    if (filteredChars.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 40px; color: #64748B;">${isSearching ? t('Không có dữ liệu phù hợp') : t('Không có nhân vật nào')}</td></tr>`;
        if (emptyState) emptyState.classList.add('hidden');
        if (paginationWrapper) paginationWrapper.classList.add('hidden');
        return;
    }

    if (emptyState) emptyState.classList.add('hidden');
    if (paginationWrapper) paginationWrapper.classList.remove('hidden');

    tbody.innerHTML = pageData.map((c) => `
        <tr>
            <td><span class="badge badge--info">${c.id}</span></td>
            <td>
                <div class="char-avatar-info">
                    <img src="${c.img}" alt="${c.name}">
                    <span class="char-name">${c.name}</span>
                </div>
            </td>
            <td>${c.job}</td>
            <td><span class="badge ${c.genderClass}">${c.gender}</span></td>
            <td class="text-right">
                <div class="action-icons">
                    <button class="btn-icon" aria-label="${t('Xem chi tiết')}" onclick="window.location.href='digital-view.html?id=${c.id}'"><i data-lucide="eye"></i></button>
                    <button class="btn-icon" aria-label="${t('Chỉnh sửa')}" onclick="window.location.href='digital-edit.html?id=${c.id}'"><i data-lucide="edit-3"></i></button>
                    <button class="btn-icon btn-icon--danger" aria-label="${t('Xóa nhân vật')}" onclick="confirmDeleteChar('${c.id}')"><i data-lucide="trash-2"></i></button>
                </div>
            </td>
        </tr>
    `).join('');

    if (window.lucide) lucide.createIcons();
    renderDigitalPagination();
    updateDigitalCount();
}

function renderDigitalPagination() {
    const totalPages = Math.ceil(filteredChars.length / DIGITAL_PAGE_SIZE);
    const nav = document.querySelector('.pagination-controls');
    if (!nav) return;

    let html = `<button class="page-link" aria-label="${t('Chuyển trang')}" ${digitalPage === 1 ? 'disabled' : ''} onclick="changeDigitalPage(${digitalPage - 1})"><i data-lucide="chevron-left" class="nav-icon"></i></button>`;

    for (let i = 1; i <= totalPages; i++) {
        if (totalPages > 6 && i > 3 && i < totalPages - 1) {
            if (i === 4) html += '<span class="page-dots">...</span>';
            continue;
        }
        html += `<button class="page-link ${i === digitalPage ? 'active' : ''}" onclick="changeDigitalPage(${i})">${i}</button>`;
    }

    html += `<button class="page-link" aria-label="${t('Chuyển trang')}" ${digitalPage === totalPages ? 'disabled' : ''} onclick="changeDigitalPage(${digitalPage + 1})"><i data-lucide="chevron-right" class="nav-icon"></i></button>`;
    nav.innerHTML = html;
    if (window.lucide) lucide.createIcons();
}

function updateDigitalCount() {
    const el = document.querySelector('.pagination-count');
    if (!el) return;

    if (filteredChars.length === 0) {
        el.textContent = '';
        return;
    }

    const start = (digitalPage - 1) * DIGITAL_PAGE_SIZE + 1;
    const end = Math.min(digitalPage * DIGITAL_PAGE_SIZE, filteredChars.length);
    el.textContent = tf('Hiển thị {start} đến {end} trong số {count} nhân vật', {
        start,
        end,
        count: filteredChars.length
    });
}

function changeDigitalPage(page) {
    const totalPages = Math.ceil(filteredChars.length / DIGITAL_PAGE_SIZE);
    if (page < 1 || page > totalPages) return;
    digitalPage = page;
    renderDigitalTable();
}

function initDigitalSearch() {
    const input = document.querySelector('.search-field-shared input');
    if (!input) return;

    input.addEventListener('input', () => {
        const q = input.value.toLowerCase().trim();
        isSearching = q.length > 0;
        filteredChars = q
            ? characters.filter((c) =>
                c.name.toLowerCase().includes(q) ||
                c.id.toLowerCase().includes(q) ||
                c.job.toLowerCase().includes(q)
            )
            : [...characters];

        digitalPage = 1;
        renderDigitalTable();
    });
}

function confirmDeleteChar(id) {
    confirmModal({
        type: 'danger',
        title: t('Xóa nhân vật số?'),
        message: t('Hành động này không thể hoàn tác. Tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.'),
        onConfirm: async () => {
            try {
                await fetch(`${API}/${id}`, { method: 'DELETE' });
                await fetchDigitalCharacters();
                showToastMessage(t('Đã xóa nhân vật thành công!'));
            } catch (error) {
                console.error(error);
                showToastMessage(t('Xóa thất bại!'));
            }
        }
    });
}

function initAvatarUpload() {
    const avatarBox = document.getElementById('avatarBox');
    const avatarInput = document.getElementById('avatarInput');
    const avatarPreview = document.getElementById('avatarPreview');
    const uploadIcon = document.getElementById('uploadIcon');
    const uploadText = document.getElementById('uploadText');
    const btnRemoveAvatar = document.getElementById('btnRemoveAvatar');

    if (avatarBox && avatarInput) {
        avatarBox.addEventListener('click', () => avatarInput.click());

        avatarInput.addEventListener('change', () => {
            const file = avatarInput.files?.[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = (e) => {
                if (avatarPreview) {
                    avatarPreview.src = e.target?.result || '';
                    avatarPreview.classList.remove('hidden');
                }
                uploadIcon?.classList.add('hidden');
                uploadText?.classList.add('hidden');
                btnRemoveAvatar?.classList.remove('hidden');
            };
            reader.readAsDataURL(file);
        });
    }

    btnRemoveAvatar?.addEventListener('click', (e) => {
        e.stopPropagation();
        if (avatarInput) avatarInput.value = '';
        if (avatarPreview) {
            avatarPreview.src = '';
            avatarPreview.classList.add('hidden');
        }
        uploadIcon?.classList.remove('hidden');
        uploadText?.classList.remove('hidden');
        btnRemoveAvatar.classList.add('hidden');
    });
}

function initDigitalForm() {
    const btnSave = document.getElementById('btnSave');
    const btnCancel = document.getElementById('btnCancel');
    const btnBack = document.getElementById('btnBack');

    btnBack?.addEventListener('click', () => {
        window.location.href = './digital.html';
    });

    btnCancel?.addEventListener('click', () => {
        window.location.href = './digital.html';
    });

    btnSave?.addEventListener('click', () => {
        confirmModal({
            title: t('Xác nhận lưu'),
            message: t('Bạn có chắc chắn muốn lưu các thay đổi này không?'),
            onConfirm: async () => {
                const pageMode = getCurrentDigitalPage();
                const digitalId = document.getElementById('digitalId');
                const digitalName = document.getElementById('digitalName');
                const gender = document.getElementById('gender');
                const jobId = document.getElementById('jobId');
                const appearance = document.getElementById('appearance');
                const systemPrompt = document.getElementById('systemPrompt');
                const avatarInput = document.getElementById('avatarInput');
                const avatarPreview = document.getElementById('avatarPreview');

                const form = new FormData();
                form.append('id', digitalId?.value || '');
                form.append('name', digitalName?.value || '');
                form.append('gender', gender?.value || '');
                form.append('jobId', jobId?.value || '');
                form.append('appearance', appearance?.value || '');
                form.append('prompt', systemPrompt?.value || '');

                const file = avatarInput?.files?.[0];
                if (file) {
                    form.append('avatar', file);
                } else if (avatarPreview?.src) {
                    form.append('image', toStoredImagePath(avatarPreview.src));
                }

                try {
                    if (pageMode === 'digital-add') {
                        const res = await fetch(API, { method: 'POST', body: form });
                        const json = await res.json();
                        if (!json?.success) {
                            showToastMessage(json?.message || t('Thêm thất bại'));
                            return;
                        }
                        showToastMessage(t('Thêm thành công'));
                    }

                    if (pageMode === 'digital-edit') {
                        const id = new URLSearchParams(window.location.search).get('id');
                        await fetch(`${API}/${id}`, { method: 'PUT', body: form });
                        showToastMessage(t('Cập nhật thành công'));
                    }

                    setTimeout(() => {
                        window.location.href = './digital.html';
                    }, 900);
                } catch (error) {
                    console.error(error);
                    showToastMessage(t('Lưu thất bại!'));
                }
            }
        });
    });

    const genderSwitcher = document.getElementById('genderSwitcher');
    const genderInput = document.getElementById('gender');
    if (genderSwitcher && genderInput) {
        genderSwitcher.querySelectorAll('.gender-opt').forEach((opt) => {
            opt.addEventListener('click', () => {
                genderSwitcher.querySelectorAll('.gender-opt').forEach((b) => b.classList.remove('active'));
                opt.classList.add('active');
                genderInput.value = opt.dataset.value;
            });
        });
    }

    initAvatarUpload();
}

function confirmAddChar() {
    showToastMessage(t('Đã thêm nhân vật thành công!'));
    setTimeout(() => window.location.href = 'digital.html', 800);
}

function confirmEditChar() {
    showToastMessage(t('Cập nhật thông tin thành công!'));
    setTimeout(() => window.location.href = 'digital.html', 800);
}

document.addEventListener('DOMContentLoaded', async () => {
    const page = getCurrentDigitalPage();

    if (page === 'digital') {
        await fetchDigitalCharacters();
        initDigitalSearch();
        return;
    }

    if (page === 'digital-view') {
        const id = new URLSearchParams(window.location.search).get('id');
        const btnBack = document.getElementById('btnBack');
        btnBack?.addEventListener('click', () => {
            window.location.href = './digital.html';
        });
        await loadDigitalDetail(id);
        return;
    }

    if (page === 'digital-add' || page === 'digital-edit') {
        initDigitalForm();
    }

    if (page === 'digital-edit') {
        const id = new URLSearchParams(window.location.search).get('id');
        await preloadDigitalForm(id);
    }
});

document.addEventListener('care-ai-language-changed', async () => {
    const page = getCurrentDigitalPage();
    if (page === 'digital') {
        characters = characters.map((c) => ({
            ...c,
            gender: (c.genderRaw === 1 || c.genderRaw === true || c.genderRaw === '1') ? t('Nam') : t('Nữ')
        }));
        filteredChars = filteredChars.map((c) => ({
            ...c,
            gender: (c.genderRaw === 1 || c.genderRaw === true || c.genderRaw === '1') ? t('Nam') : t('Nữ')
        }));
        renderDigitalTable();
    }

    if (page === 'digital-view') {
        const id = new URLSearchParams(window.location.search).get('id');
        await loadDigitalDetail(id);
    }
});
