import { useEffect, useState } from 'react';

type Health = { status: string; service: string };

const services = [
  { title: 'الفيزا العلاجية', description: 'خدمات التأشيرة للسفر بغرض العلاج في تركيا.', icon: '✚' },
  { title: 'الفيزا الطلابية', description: 'خدمات التأشيرة للدراسة والقبول الجامعي.', icon: '▤' },
  { title: 'الفيزا التجارية', description: 'خدمات التأشيرة للأعمال والزيارات التجارية.', icon: '▣' },
  { title: 'الدعوات والمعارض', description: 'خدمات التأشيرة لحضور الدعوات والمعارض.', icon: '◇' },
];

export default function App() {
  const [health, setHealth] = useState<Health | null>(null);
  const apiBase = import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:8787';

  useEffect(() => {
    fetch(`${apiBase}/api/health`)
      .then((response) => response.json() as Promise<Health>)
      .then(setHealth)
      .catch(() => setHealth(null));
  }, [apiBase]);

  return (
    <main className="page-shell">
      <header className="topbar">
        <a className="brand" href="/" aria-label="فيزتو - الرئيسية">
          <span className="brand-mark">V</span>
          <span><strong>VIZTOS</strong><small>فيزتو لخدمات التأشيرات</small></span>
        </a>
        <button className="account-button" type="button" disabled>حسابي</button>
      </header>

      <section className="hero">
        <span className="eyebrow">خدمات التأشيرات إلى تركيا</span>
        <h1>رحلتك تبدأ من هنا</h1>
        <p>اختر الخدمة المناسبة، تعرّف على المتطلبات، ثم احجز موعدك بسهولة.</p>
        <button className="google-button" type="button" disabled>
          <span aria-hidden="true">G</span> تسجيل الدخول بواسطة Google — سيُفعّل في المرحلة التالية
        </button>
      </section>

      <section className="services-section">
        <div className="section-heading">
          <div><span className="eyebrow">خدماتنا</span><h2>اختر نوع الخدمة</h2></div>
          <span className="step-label">الخطوة ١ من ٣</span>
        </div>
        <div className="service-grid">
          {services.map((service) => (
            <article className="service-card" key={service.title}>
              <span className="service-icon">{service.icon}</span>
              <h3>{service.title}</h3>
              <p>{service.description}</p>
              <button type="button" disabled>التفاصيل والحجز <span>←</span></button>
            </article>
          ))}
        </div>
      </section>

      <section className="notice">
        <strong>نسخة تأسيسية</strong>
        <p>هذه واجهة أولية للتحقق من إعداد React وربطها بخادم Cloudflare Worker. وظائف الدخول والحجز ورفع المستندات ستُنفّذ في المراحل التالية.</p>
        <small>حالة اتصال الخادم: {health ? `متصل (${health.status})` : 'بانتظار تشغيل Worker'}</small>
      </section>

      <footer>
        <strong>VIZTOS – فيزتو</strong>
        <p>حلب – الجميلية، برج حلب التجاري، الطابق الخامس، المكتب رقم 2</p>
        <p dir="ltr">00936944321492 · viztos7@gmail.com</p>
        <a href="https://viztos.com/" target="_blank" rel="noreferrer">viztos.com</a>
      </footer>
    </main>
  );
}
