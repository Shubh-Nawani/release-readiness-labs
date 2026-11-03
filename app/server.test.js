const { test } = require('node:test');
const assert = require('node:assert/strict');
const app = require('./server');
const { version } = require('./package.json');

test('release endpoints return real HTTP responses', async (t) => {
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  t.after(() => new Promise(resolve => server.close(resolve)));
  const base = `http://127.0.0.1:${server.address().port}`;
  await t.test('home endpoint responds with the application greeting', async () => {
    const response = await fetch(base);
    assert.equal(response.status, 200);
    assert.equal(await response.text(), 'Welcome to the Release Readiness Lab API');
  });
  await t.test('health endpoint reports the exact release version', async () => {
    const response = await fetch(`${base}/health`);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { status: 'ok', version });
  });
  await t.test('unknown routes return 404', async () => {
    assert.equal((await fetch(`${base}/missing`)).status, 404);
  });
});
