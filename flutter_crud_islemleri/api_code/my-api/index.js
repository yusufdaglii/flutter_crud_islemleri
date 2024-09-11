const express = require('express');
const sql = require('mssql');
const app = express();
const port = 3000;

// Veritabanı bağlantı ayarları
const config = {
    user: 'sa',
    password: '1',
    server: 'YUSUF-MONSTER',
    database: 'flutter_deneme',
    options: {
        encrypt: false, 
        trustServerCertificate: true 
    }
};

app.use(express.json());

// Verileri almak için GET isteği
app.get('/api/products', async (req, res) => {
  try {
    let pool = await sql.connect(config);
    let result = await pool.request().query('SELECT [id], [name], [price] FROM [dbo].[deneme_flutter]');
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

// Verileri eklemek için POST isteği (id otomatik olarak atanacak)
app.post('/api/products', async (req, res) => {
  const { name, price } = req.body; // id yok
  try {
    let pool = await sql.connect(config);
    await pool.request()
      .input('name', sql.NVarChar, name)
      .input('price', sql.Decimal(18, 2), price) // price için Decimal(18,2) veya SQL'deki veri türünüze göre Float olarak kullanabilirsiniz
      .query('INSERT INTO [dbo].[deneme_flutter] (name, price) VALUES (@name, @price)');
    res.status(201).send('Product added');
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

// Verileri güncellemek için PUT isteği
app.put('/api/products/:id', async (req, res) => {
  const { id } = req.params;
  const { name, price } = req.body;
  try {
    let pool = await sql.connect(config);
    await pool.request()
      .input('id', sql.Int, id)
      .input('name', sql.NVarChar, name)
      .input('price', sql.Decimal(18, 2), price)
      .query('UPDATE [dbo].[deneme_flutter] SET name = @name, price = @price WHERE id = @id');
    res.status(200).send('Product updated');
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

// Verileri silmek için DELETE isteği
app.delete('/api/products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    let pool = await sql.connect(config);
    await pool.request()
      .input('id', sql.Int, id)
      .query('DELETE FROM [dbo].[deneme_flutter] WHERE id = @id');
    res.status(200).send('Product deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

app.listen(port, () => {
  console.log('Server running at http://localhost:${port}');
});