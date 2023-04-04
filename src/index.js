import express from 'express';
import https from 'https';
import dotenv from 'dotenv';
import fs from 'fs';

// GENERAL SETUP
// ---------

dotenv.config();

function getKeyList() {
  if(!fs.existsSync('keyList.json')) {
    fs.writeFileSync('keyList.json', '[\n\t{\n\tname:"Example de nom",\n\tkey:"Exemple de clé"\n\t},\n]');
  }
  return JSON.parse(fs.readFileSync('keyList.json', 'utf8'));
}

const keyList = getKeyList();

let lowercase = [];
let uppercase  = [];
let digits  = [];
let specials  = [];

// EXPRESS SETUP
// -------------

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const options = {
  key: fs.readFileSync('keys/key.pem'),
  cert: fs.readFileSync('keys/cert.pem')
};

// CHARACTER LIST GENERATOR
// 
function charList (p, q, d = 1) {
  const a = p.charCodeAt(0),
    z = q.charCodeAt(0);
  return [...Array(Math.floor((z - a) / d) + 1)].map((e, i) =>
    String.fromCharCode(a + i * d)
  );
};

// AUTHENTICATION MIDDLEWARE
// -------------------------

const authenticationMiddleware = (req, res, next) => {
  const key = req.header("x-api-key");
  if (key == null || key == undefined) {
      return res.sendStatus(401);
  }
  if (keyList.find((elem) => elem.key === key)) {
    next();
  }
  return res.sendStatus(403);
};


// ROUTES
// ------

app.get('/', (req, res) => {
  res.send('Hello World!')
});

app.post('/generate', authenticationMiddleware, (req, res, next) => {
  let size = req.body.size ? req.body.size : 20;
  let allowed = req.body.allowed ? req.body.allowed : '';
  let filter = req.body.filter ? req.body.filter : '';

  let charDB = [];
  let password = '';

  // CHARACTER SETS
  allowed = (allowed > '' ? allowed : 'aADS');
  for (const set of allowed) {
    switch (set) {
      case 'a':
        charDB = charDB.concat(lowercase);
        break;
      case 'A':
        charDB = charDB.concat(uppercase);
        break;
      case 'D':
        charDB = charDB.concat(digits);
        break;
      case 'S':
        charDB = charDB.concat(specials);
        break;
    }
  }
  ;

  // CHARACTER FILTERING
  charDB = charDB.filter(char => !filter.includes(char));

  // PASSWORD GENERATION
  size = (size > '' ? size : '20');
  for (let i = 0; i < size; i++) {
    password = password + charDB[Math.floor(Math.random() * charDB.length)];
  }

  // PASSWORD ENTROPY
  let entropy;
  entropy = size * (Math.log(charDB.length) / Math.log(2));
  console.log(entropy);

  res.status(200).json({password, entropy});
});

// STARTUP
// -------

https.createServer(options, app).listen(process.env.PORT_NODE, () => {
  console.log('CreaPass app listening on port ' + process.env.PORT_NODE);
  lowercase = charList('a', 'z');
  uppercase = charList('A', 'Z');
  digits = charList('0', '9');
  specials = '&#-_@+-*$€?!'.split('');
});
