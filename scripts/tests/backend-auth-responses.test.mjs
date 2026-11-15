import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import { stripTypeScriptTypes } from 'node:module';

function handler(name, configured = true) {
    let serve;
    const code = fs.readFileSync(`supabase/functions/${name}/index.ts`, 'utf8').replace(/^import .*;\r?\n/gm, '');
    const context = vm.createContext({
        Response, Request,
        Deno: {
            env: { get: key => configured ? ({ SUPABASE_URL: 'https://example.invalid', SUPABASE_ANON_KEY: 'public-test-key', SUPABASE_SERVICE_ROLE_KEY: 'test-service-key', STORE_ACCESS_PASSWORD: 'test-only' })[key] : undefined },
            serve: callback => { serve = callback; }
        },
        createClient: () => ({ auth: { getUser: async () => ({ data: { user: null }, error: { message: 'Invalid session' } }) } })
    });
    vm.runInContext(stripTypeScriptTypes(code), context);
    return serve;
}

for (const name of ['admin-create-member', 'verify-store-password']) {
    test(`${name}: missing authorization is 401, including when secrets are absent`, async () => {
        for (const configured of [false, true]) {
            const response = await handler(name, configured)(new Request('https://example.invalid', { method: 'POST' }));
            assert.equal(response.status, 401);
            assert.match((await response.json()).error, /Sign in/);
        }
    });
    test(`${name}: missing server configuration is 503 for a request with authorization`, async () => {
        const response = await handler(name, false)(new Request('https://example.invalid', { method: 'POST', headers: { Authorization: 'Bearer test-only' } }));
        assert.equal(response.status, 503);
    });
    test(`${name}: invalid identity is rejected without entering protected operations`, async () => {
        const response = await handler(name)(new Request('https://example.invalid', { method: 'POST', headers: { Authorization: 'Bearer test-only' } }));
        assert.equal(response.status, 401);
    });
}
