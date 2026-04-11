function initNavigationFeedback() {
    const observer = new MutationObserver((mutations) => {
        const sidebar = document.getElementById('sidebar');
        if (sidebar) {
            attachLinkListeners(sidebar);
            observer.disconnect();
        }
    });

    observer.observe(document.body, { childList: true, subtree: true });

    function attachLinkListeners(parent) {
        const sidebarLinks = parent.querySelectorAll('.sidebar__link');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', function (e) {
                const href = this.getAttribute('href');
                if (href && !href.startsWith('#') && !href.includes('javascript:')) {
                    sidebarLinks.forEach(l => l.classList.remove('is-navigating'));
                    this.classList.add('is-navigating');
                }
            });
        });
    }
}
