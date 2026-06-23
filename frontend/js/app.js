// ============================================
// EduCloud - Frontend JavaScript
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 EduCloud - Plataforma Educativa');
    console.log('📚 Bienvenido a tu experiencia de aprendizaje');

    // ============================================
    // 1. NAVBAR MOBILE TOGGLE
    // ============================================
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            navToggle.textContent = navMenu.classList.contains('active') ? '✕' : '☰';
        });
    }

    // ============================================
    // 2. SMOOTH SCROLL
    // ============================================
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                // Cerrar menú mobile
                if (navMenu) navMenu.classList.remove('active');
                if (navToggle) navToggle.textContent = '☰';
            }
        });
    });

    // ============================================
    // 3. BOTÓN DE LOGIN
    // ============================================
    const loginBtn = document.getElementById('btn-login');
    if (loginBtn) {
        loginBtn.addEventListener('click', () => {
            // Redirigir a Cognito (cuando esté configurado)
            alert('🔐 Funcionalidad de login - Próximamente');
            console.log('🔐 Login button clicked');
        });
    }

    // ============================================
    // 4. ANIMACIÓN DE ENTRADA
    // ============================================
    const featureCards = document.querySelectorAll('.feature-card');
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, index * 100);
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    featureCards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });

    // ============================================
    // 5. CONEXIÓN CON AWS (cuando esté configurado)
    // ============================================
    async function checkBackendHealth() {
        try {
            // Aquí irá la llamada a la API Gateway
            // const response = await fetch('https://api.educloud.com/health');
            // const data = await response.json();
            // console.log('✅ Backend saludable:', data);
        } catch (error) {
            console.log('ℹ️ Backend no disponible (esto es normal en desarrollo)');
        }
    }

    checkBackendHealth();

    // ============================================
    // 6. CONFIGURACIÓN DE COGNITO (cuando esté listo)
    // ============================================
    const cognitoConfig = {
        // userPoolId: '${aws_cognito_user_pool.this.id}',
        // clientId: '${aws_cognito_user_pool_client.this.id}',
        // region: 'us-east-1'
    };

    console.log('🔐 Cognito configurado:', cognitoConfig);
});
