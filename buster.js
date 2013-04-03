var config = module.exports;

config['Listnr tests'] = {
  environment: 'browser',
  rootPath: '.',
  libs: [],
  sources: [
    'dist/listnr.js'
  ],
  tests: [
    'dist/listnr-test.js'
  ]
};
