const I18n = (function () {
    const STORAGE_KEY = 'care_ai_lang';
    const DEFAULT_LANG = 'vi';
    const SUPPORTED_LANGS = ['vi', 'en'];

    const translations = {
        'Tổng quan hệ thống': { vi: 'Tổng quan hệ thống', en: 'System overview' },
        'Chào mừng bạn đã đến với Trang chủ!': { vi: 'Chào mừng bạn đã đến với Trang chủ!', en: 'Welcome to the Dashboard!' },
        'Chọn khoảng thời gian': { vi: 'Chọn khoảng thời gian', en: 'Select date range' },
        'XUẤT BÁO CÁO': { vi: 'XUẤT BÁO CÁO', en: 'EXPORT REPORT' },
        'NGƯỜI DÙNG MỚI': { vi: 'NGƯỜI DÙNG MỚI', en: 'NEW USERS' },
        'LƯỢT TƯƠNG TÁC': { vi: 'LƯỢT TƯƠNG TÁC', en: 'INTERACTIONS' },
        'CẢNH BÁO': { vi: 'CẢNH BÁO', en: 'ALERTS' },
        'Tăng trưởng người dùng': { vi: 'Tăng trưởng người dùng', en: 'User growth' },
        'Tương tác và thời gian sử dụng': { vi: 'Tương tác và thời gian sử dụng', en: 'Interactions and usage time' },
        'Cảnh báo bất thường gần đây': { vi: 'Cảnh báo bất thường gần đây', en: 'Recent abnormal alerts' },
        'MỨC ĐỘ': { vi: 'MỨC ĐỘ', en: 'LEVEL' },
        'MÔ TẢ CẢNH BÁO': { vi: 'MÔ TẢ CẢNH BÁO', en: 'ALERT DESCRIPTION' },
        'THỜI GIAN': { vi: 'THỜI GIAN', en: 'TIME' },
        'Xem tất cả': { vi: 'Xem tất cả', en: 'View all' },
        'Cấu hình không gian làm việc quản trị, các giao thức bảo mật và các tùy chọn vùng trên toàn hệ thống của bạn.': {
            vi: 'Cấu hình không gian làm việc quản trị, các giao thức bảo mật và các tùy chọn vùng trên toàn hệ thống của bạn.',
            en: 'Configure your admin workspace, security protocols, and regional options across the entire system.'
        },
        'Lưu cấu hình': { vi: 'Lưu cấu hình', en: 'Save configuration' },
        'Care AI': { vi: 'Care AI', en: 'Care AI' },
        'Trợ lý chăm sóc sức khỏe': { vi: 'Trợ lý chăm sóc sức khỏe', en: 'Health care assistant' },
        'Trang chủ': { vi: 'Trang chủ', en: 'Dashboard' },
        'Quản lý người dùng': { vi: 'Quản lý người dùng', en: 'User management' },
        'Quản lý nhân vật số': { vi: 'Quản lý nhân vật số', en: 'Digital characters' },
        'Cài đặt': { vi: 'Cài đặt', en: 'Settings' },
        'ĐĂNG XUẤT': { vi: 'ĐĂNG XUẤT', en: 'LOGOUT' },
        'Báo cáo': { vi: 'Báo cáo', en: 'Reports' },
        'Người dùng': { vi: 'Người dùng', en: 'Users' },
        'Nhân vật': { vi: 'Nhân vật', en: 'Characters' },
        'Hoạt động gần đây': { vi: 'Hoạt động gần đây', en: 'Recent activity' },
        'Xem tất cả hoạt động': { vi: 'Xem tất cả hoạt động', en: 'View all activity' },
        'Mở menu': { vi: 'Mở menu', en: 'Open menu' },
        'Đăng xuất?': { vi: 'Đăng xuất?', en: 'Logout?' },
        'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?': {
            vi: 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?',
            en: 'Are you sure you want to log out of the system?'
        },
        'Xác nhận': { vi: 'Xác nhận', en: 'Confirm' },
        'Hủy': { vi: 'Hủy', en: 'Cancel' },
        'Hủy bỏ': { vi: 'Hủy bỏ', en: 'Dismiss' },
        'Xuất file': { vi: 'Xuất file', en: 'Export file' },
        'Đồng ý': { vi: 'Đồng ý', en: 'OK' },
        'Danh sách người dùng': { vi: 'Danh sách người dùng', en: 'User list' },
        'Quản lý và giám sát thông tin tài khoản người dùng trong hệ thống.': {
            vi: 'Quản lý và giám sát thông tin tài khoản người dùng trong hệ thống.',
            en: 'Manage and monitor user account information in the system.'
        },
        'Tìm kiếm người dùng theo tên hoặc ID...': {
            vi: 'Tìm kiếm người dùng theo tên hoặc ID...',
            en: 'Search users by name or ID...'
        },
        'Sắp xếp': { vi: 'Sắp xếp', en: 'Sort' },
        'Họ tên A → Z': { vi: 'Họ tên A → Z', en: 'Name A → Z' },
        'Họ tên Z → A': { vi: 'Họ tên Z → A', en: 'Name Z → A' },
        'Ngày tạo mới nhất': { vi: 'Ngày tạo mới nhất', en: 'Newest created date' },
        'Ngày tạo cũ nhất': { vi: 'Ngày tạo cũ nhất', en: 'Oldest created date' },
        'NGƯỜI DÙNG': { vi: 'NGƯỜI DÙNG', en: 'USER' },
        'GIỚI TÍNH': { vi: 'GIỚI TÍNH', en: 'GENDER' },
        'SỐ ĐIỆN THOẠI': { vi: 'SỐ ĐIỆN THOẠI', en: 'PHONE' },
        'NGÀY TẠO': { vi: 'NGÀY TẠO', en: 'CREATED' },
        'THAO TÁC': { vi: 'THAO TÁC', en: 'ACTIONS' },
        'Đang tải...': { vi: 'Đang tải...', en: 'Loading...' },
        'Tổng người dùng': { vi: 'Tổng người dùng', en: 'Total users' },
        'Người dùng mới tháng này': { vi: 'Người dùng mới tháng này', en: 'New users this month' },
        'Tỷ lệ tương tác': { vi: 'Tỷ lệ tương tác', en: 'Engagement rate' },
        'Dựa trên 7 ngày hoạt động gần nhất': {
            vi: 'Dựa trên 7 ngày hoạt động gần nhất',
            en: 'Based on the last 7 days of activity'
        },
        'Không có dữ liệu phù hợp': { vi: 'Không có dữ liệu phù hợp', en: 'No matching data' },
        'Không có nhân vật nào': { vi: 'Không có nhân vật nào', en: 'No characters found' },
        'Không có dữ liệu': { vi: 'Không có dữ liệu', en: 'No data available' },
        'Cài đặt': { vi: 'Cài đặt', en: 'Settings' },
        'Cài đặt hệ thống': { vi: 'Cài đặt hệ thống', en: 'System settings' },
        'Ngôn ngữ giao diện': { vi: 'Ngôn ngữ giao diện', en: 'Interface language' },
        'Đặt ngôn ngữ chung cho tất cả các bảng điều khiển<br>và báo cáo siêu dữ liệu nhân vật tự động.': {
            vi: 'Đặt ngôn ngữ chung cho tất cả các bảng điều khiển<br>và báo cáo siêu dữ liệu nhân vật tự động.',
            en: 'Set the default language for all dashboards and character metadata reports.'
        },
        'Giao diện trực quan': { vi: 'Giao diện trực quan', en: 'Visual theme' },
        'Chuyển đổi giữa chế độ Sáng độ tương phản cao<br>và chế độ Tối khí quyển.': {
            vi: 'Chuyển đổi giữa chế độ Sáng độ tương phản cao<br>và chế độ Tối khí quyển.',
            en: 'Switch between high contrast Light mode and atmospheric Dark mode.'
        },
        'Tiếng việt': { vi: 'Tiếng việt', en: 'Vietnamese' },
        'English': { vi: 'English', en: 'English' },
        'Mật khẩu mới không khớp!': { vi: 'Mật khẩu mới không khớp!', en: 'New password does not match!' },
        'Vui lòng điền đầy đủ các trường mật khẩu': { vi: 'Vui lòng điền đầy đủ các trường mật khẩu', en: 'Please fill in all password fields' },
        'Xác nhận đổi mật khẩu': { vi: 'Xác nhận đổi mật khẩu', en: 'Confirm password change' },
        'Bạn có chắc chắn muốn thay đổi mật khẩu không?': { vi: 'Bạn có chắc chắn muốn thay đổi mật khẩu không?', en: 'Are you sure you want to change the password?' },
        'Đổi mật khẩu thành công!': { vi: 'Đổi mật khẩu thành công!', en: 'Password changed successfully!' },
        'Có lỗi xảy ra': { vi: 'Có lỗi xảy ra', en: 'An error occurred' },
        'Không thể kết nối đến server': { vi: 'Không thể kết nối đến server', en: 'Cannot connect to server' },
        'Xác nhận lưu thay đổi': { vi: 'Xác nhận lưu thay đổi', en: 'Confirm save changes' },
        'Bạn có chắc chắn muốn cập nhật thông tin không?': { vi: 'Bạn có chắc chắn muốn cập nhật thông tin không?', en: 'Are you sure you want to update the information?' },
        'Cài đặt đã được cập nhật thành công!': { vi: 'Cài đặt đã được cập nhật thành công!', en: 'Settings have been updated successfully!' },
        'Cấu hình thông báo đã được lưu!': { vi: 'Cấu hình thông báo đã được lưu!', en: 'Notification settings have been saved!' },
        'Đã hủy thay đổi.': { vi: 'Đã hủy thay đổi.', en: 'Changes canceled.' },
        'Đã đổi ngôn ngữ sang ': { vi: 'Đã đổi ngôn ngữ sang ', en: 'Language changed to ' },
        'Đã chuyển sang giao diện ': { vi: 'Đã chuyển sang giao diện ', en: 'Switched to ' },
        'Sáng': { vi: 'Sáng', en: 'Light' },
        'Tối': { vi: 'Tối', en: 'Dark' },
        'Hồ sơ Admin': { vi: 'Hồ sơ Admin', en: 'Admin profile' },
        'Nhật ký bảo mật': { vi: 'Nhật ký bảo mật', en: 'Security logs' },
        'Quy tắc thông báo': { vi: 'Quy tắc thông báo', en: 'Notification rules' },
        'SỐ ĐIỆN THOẠI': { vi: 'SỐ ĐIỆN THOẠI', en: 'PHONE NUMBER' },
        'THAY ĐỔI MẬT KHẨU': { vi: 'THAY ĐỔI MẬT KHẨU', en: 'CHANGE PASSWORD' },
        'MẬT KHẨU CŨ': { vi: 'MẬT KHẨU CŨ', en: 'OLD PASSWORD' },
        'MẬT KHẨU MỚI': { vi: 'MẬT KHẨU MỚI', en: 'NEW PASSWORD' },
        'XÁC NHẬN MẬT KHẨU': { vi: 'XÁC NHẬN MẬT KHẨU', en: 'CONFIRM PASSWORD' },
        'Hủy thay đổi': { vi: 'Hủy thay đổi', en: 'Discard changes' },
        'Cập nhật danh tính': { vi: 'Cập nhật danh tính', en: 'Update profile' }
    };

    Object.assign(translations, {
        'Đóng': { vi: 'Đóng', en: 'Close' },
        'Tất cả hoạt động gần đây': { vi: 'Tất cả hoạt động gần đây', en: 'All recent activities' },
        'Tất cả cảnh báo bất thường': { vi: 'Tất cả cảnh báo bất thường', en: 'All abnormal alerts' },
        'Đang tải dữ liệu cảnh báo...': { vi: 'Đang tải dữ liệu cảnh báo...', en: 'Loading alert data...' },
        'Lỗi khi kết nối đến máy chủ.': { vi: 'Lỗi khi kết nối đến máy chủ.', en: 'Error connecting to the server.' },
        'TỔNG NGƯỜI DÙNG': { vi: 'TỔNG NGƯỜI DÙNG', en: 'TOTAL USERS' },
        'Sắp xếp người dùng': { vi: 'Sắp xếp người dùng', en: 'Sort users' },
        '! ƯU TIÊN CAO': { vi: '! ƯU TIÊN CAO', en: '! HIGH PRIORITY' },
        '✱ KHẨN CẤP': { vi: '✱ KHẨN CẤP', en: '✱ URGENT' },
        'Tổng Quan Hệ Thống | Care AI': { vi: 'Tổng Quan Hệ Thống | Care AI', en: 'System Overview | Care AI' },
        'Danh sách người dùng | Care AI': { vi: 'Danh sách người dùng | Care AI', en: 'User List | Care AI' },
        'Thư viện nhân vật | Care AI': { vi: 'Thư viện nhân vật | Care AI', en: 'Character Library | Care AI' },
        'Chi tiết nhân vật | Care AI': { vi: 'Chi tiết nhân vật | Care AI', en: 'Character Details | Care AI' },
        'Thêm nhân vật số | Care AI': { vi: 'Thêm nhân vật số | Care AI', en: 'Add Digital Character | Care AI' },
        'Chỉnh sửa nhân vật | Care AI': { vi: 'Chỉnh sửa nhân vật | Care AI', en: 'Edit Character | Care AI' },
        'Chi tiết người dùng | Care AI': { vi: 'Chi tiết người dùng | Care AI', en: 'User Details | Care AI' },
        'Chỉnh sửa người dùng | Care AI': { vi: 'Chỉnh sửa người dùng | Care AI', en: 'Edit User | Care AI' },
        'Hồ sơ Admin | Care AI': { vi: 'Hồ sơ Admin | Care AI', en: 'Admin Profile | Care AI' },
        'Cài đặt hệ thống | Care AI': { vi: 'Cài đặt hệ thống | Care AI', en: 'System Settings | Care AI' },
        'Nhật ký bảo mật | Care AI': { vi: 'Nhật ký bảo mật | Care AI', en: 'Security Logs | Care AI' },
        'Quy tắc thông báo | Care AI': { vi: 'Quy tắc thông báo | Care AI', en: 'Notification Rules | Care AI' },
        'Admin Login': { vi: 'Admin Login', en: 'Admin Login' },
        'Đăng nhập': { vi: 'Đăng nhập', en: 'Login' },
        'Nhập thông tin đăng nhập của bạn để truy cập bảng quản trị.': {
            vi: 'Nhập thông tin đăng nhập của bạn để truy cập bảng quản trị.',
            en: 'Enter your credentials to access the admin dashboard.'
        },
        'Số điện thoại': { vi: 'Số điện thoại', en: 'Phone number' },
        'Mật khẩu': { vi: 'Mật khẩu', en: 'Password' },
        'Nhập mật khẩu': { vi: 'Nhập mật khẩu', en: 'Enter password' },
        'Hiển thị/Ẩn mật khẩu': { vi: 'Hiển thị/Ẩn mật khẩu', en: 'Show/Hide password' },
        'Tài khoản dùng thử: 09xxxxxxxx / admin123': {
            vi: 'Tài khoản dùng thử: 09xxxxxxxx / admin123',
            en: 'Demo account: 09xxxxxxxx / admin123'
        },
        'Vui lòng nhập số điện thoại và mật khẩu': {
            vi: 'Vui lòng nhập số điện thoại và mật khẩu',
            en: 'Please enter phone number and password'
        },
        'Đăng nhập thất bại': { vi: 'Đăng nhập thất bại', en: 'Login failed' },
        'Người dùng mới': { vi: 'Người dùng mới', en: 'New users' },
        'Lượt tương tác': { vi: 'Lượt tương tác', en: 'Interactions' },
        'Vừa xong': { vi: 'Vừa xong', en: 'Just now' },
        '{count} phút trước': { vi: '{count} phút trước', en: '{count} minutes ago' },
        '{count} giờ trước': { vi: '{count} giờ trước', en: '{count} hours ago' },
        '{count} ngày trước': { vi: '{count} ngày trước', en: '{count} days ago' },
        'TRUNG BÌNH': { vi: 'TRUNG BÌNH', en: 'MEDIUM' },
        'NHẸ': { vi: 'NHẸ', en: 'LOW' },
        'CAO': { vi: 'CAO', en: 'HIGH' },
        'Không có cảnh báo nào gần đây.': {
            vi: 'Không có cảnh báo nào gần đây.',
            en: 'No recent alerts.'
        },
        'Người dùng ID #{id}': { vi: 'Người dùng ID #{id}', en: 'User ID #{id}' },
        'Hệ thống': { vi: 'Hệ thống', en: 'System' },
        'Phát hiện ngôn ngữ tiêu cực: "{message}"': {
            vi: 'Phát hiện ngôn ngữ tiêu cực: "{message}"',
            en: 'Negative language detected: "{message}"'
        },
        'Cảnh báo nhịp tim: {message}': {
            vi: 'Cảnh báo nhịp tim: {message}',
            en: 'Heart rate alert: {message}'
        },
        'Cảnh báo mức độ căng thẳng: {message}': {
            vi: 'Cảnh báo mức độ căng thẳng: {message}',
            en: 'Stress level alert: {message}'
        },
        'Cảnh báo nồng độ oxy máu: {message}': {
            vi: 'Cảnh báo nồng độ oxy máu: {message}',
            en: 'Blood oxygen alert: {message}'
        },
        'Cảnh báo giấc ngủ: {message}': {
            vi: 'Cảnh báo giấc ngủ: {message}',
            en: 'Sleep alert: {message}'
        },
        'Cảnh báo sức khỏe: {message}': {
            vi: 'Cảnh báo sức khỏe: {message}',
            en: 'Health alert: {message}'
        },
        'Xuất báo cáo thành công': { vi: 'Xuất báo cáo thành công', en: 'Report exported successfully' },
        'Xác nhận xuất file': { vi: 'Xác nhận xuất file', en: 'Confirm export' },
        'Bạn có chắc chắn muốn xuất báo cáo này không?': {
            vi: 'Bạn có chắc chắn muốn xuất báo cáo này không?',
            en: 'Are you sure you want to export this report?'
        },
        'Áp dụng': { vi: 'Áp dụng', en: 'Apply' },
        'ngày': { vi: 'ngày', en: 'days' },
        '(Chưa cập nhật)': { vi: '(Chưa cập nhật)', en: '(Not updated)' },
        'Nam': { vi: 'Nam', en: 'Male' },
        'Nữ': { vi: 'Nữ', en: 'Female' },
        'Khác': { vi: 'Khác', en: 'Other' },
        'Xóa': { vi: 'Xóa', en: 'Delete' },
        'Xác nhận thao tác?': { vi: 'Xác nhận thao tác?', en: 'Confirm this action?' },
        'Xem chi tiết': { vi: 'Xem chi tiết', en: 'View details' },
        'Chỉnh sửa': { vi: 'Chỉnh sửa', en: 'Edit' },
        'Xóa người dùng': { vi: 'Xóa người dùng', en: 'Delete user' },
        'Chuyển trang': { vi: 'Chuyển trang', en: 'Change page' },
        'Hiển thị {start} đến {end} trong số {count} người dùng': {
            vi: 'Hiển thị {start} đến {end} trong số {count} người dùng',
            en: 'Showing {start} to {end} of {count} users'
        },
        'Xóa người dùng?': { vi: 'Xóa người dùng?', en: 'Delete user?' },
        'Bạn có chắc chắn muốn xóa <strong>{name}</strong>? Hành động này không thể hoàn tác.': {
            vi: 'Bạn có chắc chắn muốn xóa <strong>{name}</strong>? Hành động này không thể hoàn tác.',
            en: 'Are you sure you want to delete <strong>{name}</strong>? This action cannot be undone.'
        },
        'Xóa thất bại': { vi: 'Xóa thất bại', en: 'Delete failed' },
        'Xóa thành công': { vi: 'Xóa thành công', en: 'Deleted successfully' },
        'Lỗi kết nối server': { vi: 'Lỗi kết nối server', en: 'Server connection error' },
        'Cập nhật lần cuối: {date}': { vi: 'Cập nhật lần cuối: {date}', en: 'Last updated: {date}' },
        'Xóa tài khoản?': { vi: 'Xóa tài khoản?', en: 'Delete account?' },
        'Bạn có chắc chắn muốn xóa người dùng này không?': {
            vi: 'Bạn có chắc chắn muốn xóa người dùng này không?',
            en: 'Are you sure you want to delete this user?'
        },
        'Vui lòng chọn file ảnh': { vi: 'Vui lòng chọn file ảnh', en: 'Please select an image file' },
        'Vui lòng nhập tên người dùng': { vi: 'Vui lòng nhập tên người dùng', en: 'Please enter the user name' },
        'Người dùng phải ít nhất 16 tuổi': { vi: 'Người dùng phải ít nhất 16 tuổi', en: 'User must be at least 16 years old' },
        'Chiều cao phải từ 50 đến 300 cm': { vi: 'Chiều cao phải từ 50 đến 300 cm', en: 'Height must be between 50 and 300 cm' },
        'Cân nặng phải từ 10 đến 500 kg': { vi: 'Cân nặng phải từ 10 đến 500 kg', en: 'Weight must be between 10 and 500 kg' },
        'Email không đúng định dạng': { vi: 'Email không đúng định dạng', en: 'Invalid email format' },
        'Bạn có chắc chắn muốn lưu các thay đổi này không?': {
            vi: 'Bạn có chắc chắn muốn lưu các thay đổi này không?',
            en: 'Are you sure you want to save these changes?'
        },
        'Cập nhật thất bại': { vi: 'Cập nhật thất bại', en: 'Update failed' },
        'Cập nhật thành công': { vi: 'Cập nhật thành công', en: 'Updated successfully' },
        'Chi tiết người dùng': { vi: 'Chi tiết người dùng', en: 'User details' },
        'Chỉnh sửa thông tin': { vi: 'Chỉnh sửa thông tin', en: 'Edit information' },
        'Xóa tài khoản': { vi: 'Xóa tài khoản', en: 'Delete account' },
        'Thông tin cá nhân': { vi: 'Thông tin cá nhân', en: 'Personal information' },
        'Họ và tên': { vi: 'Họ và tên', en: 'Full name' },
        'Ngày sinh': { vi: 'Ngày sinh', en: 'Date of birth' },
        'Giới tính': { vi: 'Giới tính', en: 'Gender' },
        'Chiều cao': { vi: 'Chiều cao', en: 'Height' },
        'Cân nặng': { vi: 'Cân nặng', en: 'Weight' },
        'Thông tin liên hệ': { vi: 'Thông tin liên hệ', en: 'Contact information' },
        'Địa chỉ': { vi: 'Địa chỉ', en: 'Address' },
        'Lịch sử hoạt động gần đây': { vi: 'Lịch sử hoạt động gần đây', en: 'Recent activity history' },
        'Cập nhật thông tin sức khỏe': { vi: 'Cập nhật thông tin sức khỏe', en: 'Health information updated' },
        'Thông số nhịp tim và huyết áp đã được đồng bộ từ thiết bị đeo.': {
            vi: 'Thông số nhịp tim và huyết áp đã được đồng bộ từ thiết bị đeo.',
            en: 'Heart rate and blood pressure metrics have been synced from the wearable device.'
        },
        '15:30 - Hôm nay': { vi: '15:30 - Hôm nay', en: '15:30 - Today' },
        'Đăng nhập từ thiết bị mới': { vi: 'Đăng nhập từ thiết bị mới', en: 'Login from a new device' },
        'Trình duyệt Chrome trên MacOS (TP. HCM, Việt Nam)': {
            vi: 'Trình duyệt Chrome trên MacOS (TP. HCM, Việt Nam)',
            en: 'Chrome browser on macOS (Ho Chi Minh City, Vietnam)'
        },
        '08:12 - Hôm qua': { vi: '08:12 - Hôm qua', en: '08:12 - Yesterday' },
        'Đặt lịch khám chuyên khoa': { vi: 'Đặt lịch khám chuyên khoa', en: 'Specialist appointment booked' },
        'Lịch hẹn với Bác sĩ Nguyễn Văn A tại Bệnh viện Đa khoa Tâm Anh.': {
            vi: 'Lịch hẹn với Bác sĩ Nguyễn Văn A tại Bệnh viện Đa khoa Tâm Anh.',
            en: 'Appointment with Dr. Nguyen Van A at Tam Anh General Hospital.'
        },
        'Chỉnh sửa người dùng': { vi: 'Chỉnh sửa người dùng', en: 'Edit user' },
        'Chỉnh sửa thông tin người dùng': { vi: 'Chỉnh sửa thông tin người dùng', en: 'Edit user information' },
        'Cập nhật hồ sơ cá nhân và thông tin liên lạc của bạn để duy trì hồ sơ bệnh án chính xác.': {
            vi: 'Cập nhật hồ sơ cá nhân và thông tin liên lạc của bạn để duy trì hồ sơ bệnh án chính xác.',
            en: 'Update personal records and contact information to keep the medical profile accurate.'
        },
        'Ảnh đại diện': { vi: 'Ảnh đại diện', en: 'Profile picture' },
        'Sử dụng tệp PNG hoặc JPG dung lượng tối đa 5MB. Kích thước khuyến nghị 800×800px.': {
            vi: 'Sử dụng tệp PNG hoặc JPG dung lượng tối đa 5MB. Kích thước khuyến nghị 800×800px.',
            en: 'Use a PNG or JPG file up to 5MB. Recommended size: 800×800px.'
        },
        'Tải lên': { vi: 'Tải lên', en: 'Upload' },
        'Cập nhật hồ sơ': { vi: 'Cập nhật hồ sơ', en: 'Update profile' },
        'Thư viện nhân vật': { vi: 'Thư viện nhân vật', en: 'Character library' },
        'Kiến tạo và quản lý các đại diện kỹ thuật số thông minh trong hệ sinh thái Care AI.': {
            vi: 'Kiến tạo và quản lý các đại diện kỹ thuật số thông minh trong hệ sinh thái Care AI.',
            en: 'Create and manage intelligent digital personas in the Care AI ecosystem.'
        },
        'Tìm kiếm nhân vật theo tên hoặc ID...': {
            vi: 'Tìm kiếm nhân vật theo tên hoặc ID...',
            en: 'Search characters by name or ID...'
        },
        'Thêm nhân vật mới': { vi: 'Thêm nhân vật mới', en: 'Add new character' },
        'ẢNH ĐẠI DIỆN': { vi: 'ẢNH ĐẠI DIỆN', en: 'AVATAR' },
        'NGHỀ NGHIỆP': { vi: 'NGHỀ NGHIỆP', en: 'PROFESSION' },
        'Đại diện số không chỉ là hình ảnh, mà là nhịp cầu tri thức nối liền khoảng cách giữa công nghệ và cảm xúc con người.': {
            vi: 'Đại diện số không chỉ là hình ảnh, mà là nhịp cầu tri thức nối liền khoảng cách giữa công nghệ và cảm xúc con người.',
            en: 'A digital persona is not just an image, but a bridge of knowledge connecting technology and human emotion.'
        },
        'Chi tiết nhân vật': { vi: 'Chi tiết nhân vật', en: 'Character details' },
        'Xóa nhân vật': { vi: 'Xóa nhân vật', en: 'Delete character' },
        'THÔNG TIN CÁ NHÂN': { vi: 'THÔNG TIN CÁ NHÂN', en: 'PERSONAL INFORMATION' },
        'ĐẶC ĐIỂM & MÔ TẢ': { vi: 'ĐẶC ĐIỂM & MÔ TẢ', en: 'TRAITS & DESCRIPTION' },
        'HỌ VÀ TÊN': { vi: 'HỌ VÀ TÊN', en: 'FULL NAME' },
        'MÃ ID': { vi: 'MÃ ID', en: 'ID CODE' },
        'NGOẠI HÌNH / VỀ BỀ NGOÀI': { vi: 'NGOẠI HÌNH / VỀ BỀ NGOÀI', en: 'APPEARANCE' },
        'MÔ TẢ CHI TIẾT': { vi: 'MÔ TẢ CHI TIẾT', en: 'DETAILED DESCRIPTION' },
        'Thêm nhân vật số': { vi: 'Thêm nhân vật số', en: 'Add digital character' },
        'Thiết lập thông tin định danh cho nhân vật ảo trong hệ thống Clinical Portal.': {
            vi: 'Thiết lập thông tin định danh cho nhân vật ảo trong hệ thống Clinical Portal.',
            en: 'Set up identity information for the virtual character in the Clinical Portal system.'
        },
        'Ảnh đại diện nhân vật': { vi: 'Ảnh đại diện nhân vật', en: 'Character avatar' },
        'Tải lên hình ảnh khuôn mặt rõ nét. Định dạng hỗ trợ: JPG, PNG (Tối đa 5MB).': {
            vi: 'Tải lên hình ảnh khuôn mặt rõ nét. Định dạng hỗ trợ: JPG, PNG (Tối đa 5MB).',
            en: 'Upload a clear face image. Supported formats: JPG, PNG (up to 5MB).'
        },
        'Tải ảnh lên': { vi: 'Tải ảnh lên', en: 'Upload image' },
        'Xóa ảnh': { vi: 'Xóa ảnh', en: 'Remove image' },
        'Nhập họ và tên đầy đủ của nhân vật': {
            vi: 'Nhập họ và tên đầy đủ của nhân vật',
            en: 'Enter the character’s full name'
        },
        'Mã định danh nhân vật': { vi: 'Mã định danh nhân vật', en: 'Character identifier' },
        'Ví dụ:NV001': { vi: 'Ví dụ:NV001', en: 'Example: NV001' },
        'Nghề nghiệp / Vai trò': { vi: 'Nghề nghiệp / Vai trò', en: 'Profession / Role' },
        'Ví dụ: Bác sĩ khoa nhi, Chuyên gia dinh dưỡng...': {
            vi: 'Ví dụ: Bác sĩ khoa nhi, Chuyên gia dinh dưỡng...',
            en: 'Example: Pediatrician, Nutrition Specialist...'
        },
        'Ngoại hình': { vi: 'Ngoại hình', en: 'Appearance' },
        'Mô tả các đặc điểm nhận dạng, trang phục, sắc thái khuôn mặt...': {
            vi: 'Mô tả các đặc điểm nhận dạng, trang phục, sắc thái khuôn mặt...',
            en: 'Describe identifying features, clothing, facial expression...'
        },
        'Mô tả chi tiết': { vi: 'Mô tả chi tiết', en: 'Detailed description' },
        'Tiểu sử, tính cách, cách giao tiếp với bệnh nhân...': {
            vi: 'Tiểu sử, tính cách, cách giao tiếp với bệnh nhân...',
            en: 'Biography, personality, and communication style with patients...'
        },
        'Tạo nhân vật': { vi: 'Tạo nhân vật', en: 'Create character' },
        'Chỉnh sửa thông tin nhân vật số': { vi: 'Chỉnh sửa thông tin nhân vật số', en: 'Edit digital character information' },
        'Cập nhật hồ sơ nhân vật số để duy trì độ chính xác trong hệ thống.': {
            vi: 'Cập nhật hồ sơ nhân vật số để duy trì độ chính xác trong hệ thống.',
            en: 'Update the digital character profile to keep information accurate in the system.'
        },
        'Tải lên hình ảnh rõ nét để đại diện cho nhân vật số này.': {
            vi: 'Tải lên hình ảnh rõ nét để đại diện cho nhân vật số này.',
            en: 'Upload a clear image to represent this digital character.'
        },
        'Thông tin cá nhân': { vi: 'Thông tin cá nhân', en: 'Personal information' },
        'Lưu thay đổi': { vi: 'Lưu thay đổi', en: 'Save changes' },
        'Không có nhân vật nào': { vi: 'Không có nhân vật nào', en: 'No characters found' },
        'Hiển thị {start} đến {end} trong số {count} nhân vật': {
            vi: 'Hiển thị {start} đến {end} trong số {count} nhân vật',
            en: 'Showing {start} to {end} of {count} characters'
        },
        'Xóa nhân vật số?': { vi: 'Xóa nhân vật số?', en: 'Delete digital character?' },
        'Hành động này không thể hoàn tác. Tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.': {
            vi: 'Hành động này không thể hoàn tác. Tất cả dữ liệu liên quan sẽ bị xóa vĩnh viễn.',
            en: 'This action cannot be undone. All related data will be permanently deleted.'
        },
        'Đã xóa nhân vật thành công!': { vi: 'Đã xóa nhân vật thành công!', en: 'Character deleted successfully!' },
        'Xóa thất bại!': { vi: 'Xóa thất bại!', en: 'Delete failed!' },
        'Xác nhận lưu': { vi: 'Xác nhận lưu', en: 'Confirm save' },
        'Thêm thất bại': { vi: 'Thêm thất bại', en: 'Add failed' },
        'Thêm thành công': { vi: 'Thêm thành công', en: 'Added successfully' },
        'Lưu thất bại!': { vi: 'Lưu thất bại!', en: 'Save failed!' },
        'Đã thêm nhân vật thành công!': { vi: 'Đã thêm nhân vật thành công!', en: 'Character added successfully!' },
        'Cập nhật thông tin thành công!': { vi: 'Cập nhật thông tin thành công!', en: 'Information updated successfully!' },
        'Lọc dữ liệu': { vi: 'Lọc dữ liệu', en: 'Filter data' },
        '7 ngày qua': { vi: '7 ngày qua', en: 'Last 7 days' },
        'Loại hành động': { vi: 'Loại hành động', en: 'Action type' },
        'HÀNH ĐỘNG': { vi: 'HÀNH ĐỘNG', en: 'ACTION' },
        'NGƯỜI THỰC HIỆN': { vi: 'NGƯỜI THỰC HIỆN', en: 'PERFORMED BY' },
        'ĐỊA CHỈ IP': { vi: 'ĐỊA CHỈ IP', en: 'IP ADDRESS' },
        'TRẠNG THÁI': { vi: 'TRẠNG THÁI', en: 'STATUS' },
        'Đăng nhập hệ thống': { vi: 'Đăng nhập hệ thống', en: 'System login' },
        'THÀNH CÔNG': { vi: 'THÀNH CÔNG', en: 'SUCCESS' },
        'Thay đổi mật khẩu': { vi: 'Thay đổi mật khẩu', en: 'Password change' },
        'THẤT BẠI': { vi: 'THẤT BẠI', en: 'FAILED' },
        'Cập nhật nhân vật': { vi: 'Cập nhật nhân vật', en: 'Character update' },
        'Cảnh báo đăng nhập lạ': { vi: 'Cảnh báo đăng nhập lạ', en: 'Unusual login alert' },
        'Hệ thống AI': { vi: 'Hệ thống AI', en: 'AI system' },
        'ĐÃ CHẶN': { vi: 'ĐÃ CHẶN', en: 'BLOCKED' },
        'Hiển thị 1 - 10 trong số 1,240 nhật ký': {
            vi: 'Hiển thị 1 - 10 trong số 1,240 nhật ký',
            en: 'Showing 1 - 10 of 1,240 logs'
        },
        'Trang trước': { vi: 'Trang trước', en: 'Previous page' },
        'Trang sau': { vi: 'Trang sau', en: 'Next page' },
        'Xuất dữ liệu nhật ký': { vi: 'Xuất dữ liệu nhật ký', en: 'Export log data' },
        'Bạn có thể tải xuống toàn bộ nhật ký bảo mật dưới định dạng CSV hoặc PDF để lưu trữ ngoại tuyến.': {
            vi: 'Bạn có thể tải xuống toàn bộ nhật ký bảo mật dưới định dạng CSV hoặc PDF để lưu trữ ngoại tuyến.',
            en: 'You can download the complete security logs in CSV or PDF format for offline storage.'
        },
        'Tải CSV': { vi: 'Tải CSV', en: 'Download CSV' },
        'Tải PDF': { vi: 'Tải PDF', en: 'Download PDF' },
        'Thông báo đăng nhập mới': { vi: 'Thông báo đăng nhập mới', en: 'New login notification' },
        'Gửi cảnh báo ngay lập tức khi phát hiện tài khoản quản trị đăng nhập từ thiết bị lạ.': {
            vi: 'Gửi cảnh báo ngay lập tức khi phát hiện tài khoản quản trị đăng nhập từ thiết bị lạ.',
            en: 'Send an immediate alert when an admin account logs in from an unfamiliar device.'
        },
        'ƯU TIÊN CAO': { vi: 'ƯU TIÊN CAO', en: 'HIGH PRIORITY' },
        'Thay đổi dữ liệu nhân vật': { vi: 'Thay đổi dữ liệu nhân vật', en: 'Character data changes' },
        'Thông báo khi các thông số cốt lõi hoặc cấu hình AI của nhân vật số bị thay đổi.': {
            vi: 'Thông báo khi các thông số cốt lõi hoặc cấu hình AI của nhân vật số bị thay đổi.',
            en: 'Notify when core attributes or AI configuration of a digital character are changed.'
        },
        'NHẬT KÝ HỆ THỐNG': { vi: 'NHẬT KÝ HỆ THỐNG', en: 'SYSTEM LOG' },
        'Báo cáo hệ thống hàng tuần': { vi: 'Báo cáo hệ thống hàng tuần', en: 'Weekly system report' },
        'Tổng hợp hiệu suất AI, số lượng người dùng mới và các chỉ số vận hành.': {
            vi: 'Tổng hợp hiệu suất AI, số lượng người dùng mới và các chỉ số vận hành.',
            en: 'Summarize AI performance, new user counts, and operational metrics.'
        },
        'ĐỊNH KỲ': { vi: 'ĐỊNH KỲ', en: 'SCHEDULED' },
        'Cảnh báo bảo mật': { vi: 'Cảnh báo bảo mật', en: 'Security alert' },
        'Kích hoạt thông báo đa kênh khi có dấu hiệu tấn công Brute-force hoặc rò rỉ API Key.': {
            vi: 'Kích hoạt thông báo đa kênh khi có dấu hiệu tấn công Brute-force hoặc rò rỉ API Key.',
            en: 'Trigger multi-channel notifications when brute-force attacks or API key leaks are detected.'
        },
        'KHẨN CẤP': { vi: 'KHẨN CẤP', en: 'URGENT' },
        'Lần cập nhật cuối: 10 phút trước': { vi: 'Lần cập nhật cuối: 10 phút trước', en: 'Last updated: 10 minutes ago' },
        'Cập nhật hồ sơ bệnh nhân mới': { vi: 'Cập nhật hồ sơ bệnh nhân mới', en: 'New patient profile updated' },
        'Hệ thống vừa đồng bộ dữ liệu từ thiết bị đeo thông minh.': {
            vi: 'Hệ thống vừa đồng bộ dữ liệu từ thiết bị đeo thông minh.',
            en: 'The system has just synced data from a smart wearable device.'
        },
        '12 phút trước': { vi: '12 phút trước', en: '12 minutes ago' },
        'BS. Trần Thị B đã xem báo cáo': { vi: 'BS. Trần Thị B đã xem báo cáo', en: 'Dr. Tran Thi B viewed the report' },
        'Truy cập báo cáo tuần của Khoa Nội tổng quát.': {
            vi: 'Truy cập báo cáo tuần của Khoa Nội tổng quát.',
            en: 'Accessed the weekly report of the General Internal Medicine Department.'
        },
        '45 phút trước': { vi: '45 phút trước', en: '45 minutes ago' },
        'Tối ưu hóa mô hình AI': { vi: 'Tối ưu hóa mô hình AI', en: 'AI model optimized' },
        'Cập nhật tham số nhận diện cảm xúc giọng nói v2.4.': {
            vi: 'Cập nhật tham số nhận diện cảm xúc giọng nói v2.4.',
            en: 'Updated voice emotion recognition parameters v2.4.'
        },
        '2 giờ trước': { vi: '2 giờ trước', en: '2 hours ago' },
        'Xuất báo cáo hàng tháng': { vi: 'Xuất báo cáo hàng tháng', en: 'Monthly report exported' },
        'Báo cáo tháng 7 đã được gửi đến hội đồng quản trị.': {
            vi: 'Báo cáo tháng 7 đã được gửi đến hội đồng quản trị.',
            en: 'The July report has been sent to the board of directors.'
        },
        '4 giờ trước': { vi: '4 giờ trước', en: '4 hours ago' }
    });

    function normalizeKey(text) {
        if (typeof text !== 'string') return '';
        return text.replace(/\s+/g, ' ').trim();
    }

    const lookup = new Map();
    Object.entries(translations).forEach(([source, values]) => {
        if (typeof source === 'string') {
            lookup.set(normalizeKey(source), values);
        }
        Object.values(values).forEach((text) => {
            if (typeof text === 'string') {
                lookup.set(normalizeKey(text), values);
            }
        });
    });

    let currentLang = STORAGE_KEY && localStorage.getItem(STORAGE_KEY);
    if (!SUPPORTED_LANGS.includes(currentLang)) {
        const browserLang = navigator.language || navigator.userLanguage || DEFAULT_LANG;
        currentLang = browserLang.toLowerCase().startsWith('en') ? 'en' : 'vi';
    }

    function setLanguage(lang) {
        if (!SUPPORTED_LANGS.includes(lang)) return;
        currentLang = lang;
        document.documentElement.lang = lang === 'en' ? 'en' : 'vi';
        if (STORAGE_KEY) localStorage.setItem(STORAGE_KEY, lang);
        translateDocumentTitle();
        translatePage();
        document.dispatchEvent(new CustomEvent('care-ai-language-changed', {
            detail: { lang }
        }));
    }

    function getCurrentLang() {
        return currentLang;
    }

    function t(key) {
        if (!key || typeof key !== 'string') return key;
        const normalized = normalizeKey(key);
        const entry = translations[normalized];
        if (entry) return entry[currentLang] || key;
        const lookupEntry = lookup.get(normalized);
        return lookupEntry ? lookupEntry[currentLang] || key : key;
    }

    function translateText(text) {
        if (!text || typeof text !== 'string') return text;
        const normalized = normalizeKey(text);
        const entry = lookup.get(normalized);
        if (entry) {
            const translated = entry[currentLang];
            const leadingWhitespace = text.match(/^\s*/)?.[0] || '';
            const trailingWhitespace = text.match(/\s*$/)?.[0] || '';
            return `${leadingWhitespace}${translated}${trailingWhitespace}`;
        }
        return text;
    }

    function format(key, params = {}) {
        const template = t(key);
        if (typeof template !== 'string') return template;

        return template.replace(/\{(\w+)\}/g, (_, token) => {
            const value = params[token];
            return value === undefined || value === null ? '' : String(value);
        });
    }

    function translateDocumentTitle() {
        if (typeof document === 'undefined' || !document.title) return;
        document.title = translateText(document.title);
    }

    function translateElement(element) {
        if (!element || element.nodeType !== Node.ELEMENT_NODE) return;

        const i18nHtmlKey = element.dataset.i18nHtml;
        if (i18nHtmlKey) {
            element.innerHTML = t(i18nHtmlKey);
            return;
        }

        const i18nKey = element.dataset.i18n;
        if (i18nKey) {
            const translated = t(i18nKey);
            if ('placeholder' in element) element.placeholder = translated;
            if ('title' in element) element.title = translated;
            if (element.tagName === 'INPUT' || element.tagName === 'BUTTON') {
                if (element.value) element.value = translated;
            }
            if (element.childNodes.length === 1 && element.childNodes[0].nodeType === Node.TEXT_NODE) {
                element.childNodes[0].nodeValue = translated;
            }
        }

        ['placeholder', 'aria-label', 'title', 'alt', 'value'].forEach((attr) => {
            if (element.hasAttribute(attr)) {
                const raw = element.getAttribute(attr);
                if (raw) {
                    element.setAttribute(attr, translateText(raw));
                }
            }
        });
    }

    function translatePage(root = document.body) {
        if (!root) return;

        const elements = Array.from(root.querySelectorAll('*:not(script):not(style):not(noscript)'));
        elements.forEach((element) => {
            translateElement(element);
        });

        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
            acceptNode(node) {
                if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
                if (node.parentNode && ['SCRIPT', 'STYLE', 'NOSCRIPT'].includes(node.parentNode.tagName)) {
                    return NodeFilter.FILTER_REJECT;
                }
                return NodeFilter.FILTER_ACCEPT;
            }
        });

        let node;
        while (node = walker.nextNode()) {
            const translated = translateText(node.nodeValue);
            if (translated !== node.nodeValue) {
                node.nodeValue = translated;
            }
        }
    }

    function init() {
        document.documentElement.lang = currentLang === 'en' ? 'en' : 'vi';
        translateDocumentTitle();
        translatePage();
    }

    return {
        getCurrentLang,
        setLanguage,
        t,
        format,
        translatePage,
        init
    };
})();

if (typeof window !== 'undefined') {
    window.I18n = I18n;
}

if (typeof globalThis !== 'undefined') {
    globalThis.I18n = I18n;
}
