var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.json({ 'status':200, 'response': 'Backend says: Hello World'});
});

module.exports = router;
