export interface Env {
  DB: D1Database;
  DOCUMENTS: R2Bucket;
  APP_ENV: string;
  ALLOWED_ORIGIN: string;
}

const json = (data: unknown, status = 200, headers: HeadersInit = {}) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', ...headers },
  });

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin');
    const corsHeaders: HeadersInit = {
      'access-control-allow-origin': origin === env.ALLOWED_ORIGIN ? origin : env.ALLOWED_ORIGIN,
      'access-control-allow-methods': 'GET,POST,PATCH,DELETE,OPTIONS',
      'access-control-allow-headers': 'Content-Type,Authorization',
      'access-control-allow-credentials': 'true',
      'vary': 'Origin',
    };

    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: corsHeaders });

    if (url.pathname === '/api/health' && request.method === 'GET') {
      return json({ status: 'ok', service: 'viztos-api', environment: env.APP_ENV }, 200, corsHeaders);
    }

    return json({ error: 'NOT_FOUND', message: 'المسار غير موجود' }, 404, corsHeaders);
  },
};
