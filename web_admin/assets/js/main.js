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

(function () {
    const scripts = document.getElementsByTagName('script');
    let scriptSrc = '';
    for (let s of scripts) {
        if (s.src.includes('assets/js/main.js')) {
            scriptSrc = s.src;
            break;
        }
    }

    if (scriptSrc) {
        const rootPath = scriptSrc.split('/assets/js/')[0];
        const faviconPath = rootPath + '/assets/images/logo.png';

        let link = document.querySelector("link[rel*='icon']");
        if (!link) {
            link = document.createElement('link');
            link.rel = 'icon';
            document.head.appendChild(link);
        }
        link.href = faviconPath;
        link.type = 'image/png';
    }
})();

initNavigationFeedback();
