const { spawnSync } = require('child_process');
const readline = require('readline');

const input = readline.createInterface({ input: process.stdin });

input.on('line', (line) => {
  const event = JSON.parse(line);
  if (event.type === 'table') {
    for (const [name, currentVersion, wantedVersion, latestVersion, packageType, url] of event.data.body) {
      if (latestVersion !== 'exotic') {
        spawnSync('yarn', [
          'add',
          packageType === 'devDependencies' && '--dev',
          [
            name,
            latestVersion
          ].join('@')
        ].filter(Boolean), { stdio: 'inherit' });
      }
    }
  }
});
