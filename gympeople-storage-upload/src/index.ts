/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

interface Env {
	GYMPEOPLE_STORAGE: R2Bucket;
	AUTH_SECRET: string;
}

export default {
	async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
		const url = new URL(request.url);
		const key = url.pathname.slice(1); // Remove leading '/'

		// Allow only GET and POST
		if (request.method !== 'GET' && request.method !== 'POST') {
			return new Response('Method Not Allowed', { 
				status: 405,
				headers: { 'Allow': 'GET, POST' }
			});

		}


		// Handle POST
		if (request.method === 'POST') {
			const auth = request.headers.get('Authorization');
			const expectedAuth = `Bearer ${env.AUTH_SECRET}`;

			if (!auth || auth !== expectedAuth) {
				return new Response('Unauthorized', { status: 401 });
			}

			const contentType = request.headers.get('Content-Type') || '';
			if (!contentType.includes('multipart/form-data')) {
				return new Response('Bad Request: Content-Type must be multipart/form-data', { status: 400 });
			}

			try {
				const formData = await request.formData();
				const file = formData.get('file') as File | null;
				const customName = formData.get('filename')?.toString();

				if (!file) {
					return new Response('Bad Request: No file provided', { status: 400 });
				}

				const uploadKey = customName || file.name;
				const fileType = file.type || 'application/octet-stream';

				await env.GYMPEOPLE_STORAGE.put(uploadKey, file.stream(), {
					httpMetadata: {
						contentType: fileType,
					},
				});

				return new Response(`File uploaded successfully with key: ${uploadKey}`, { status: 201 });
			} catch (error) {
				return new Response(`Upload failed: ${(error as Error).message}`, { status: 500 });
			}

		}

		// Handle GET
		const object = await env.GYMPEOPLE_STORAGE.get(key);

		if (!object) {
			return new Response('Not Found', { status: 404 });
		}

		const headers = new Headers();
		object.writeHttpMetadata(headers);
		headers.set('etag', object.etag);

		return new Response(object.body, { status: 200, headers });
	},
} satisfies	ExportedHandler<Env>;