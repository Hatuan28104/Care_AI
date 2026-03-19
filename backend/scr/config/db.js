import sql from "mssql";

const config = {
  server: "127.0.0.1",
  port: 1433,
  database: "CAREAI",
  user: "careai_user",
  password: "123",
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
};

let pool;

export async function getDB() {
  if (pool) return pool;      

  pool = await sql.connect(config);
  console.log("DB connected");
  return pool;
}
