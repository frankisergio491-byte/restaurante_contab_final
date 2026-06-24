from pathlib import Path
import re
import sys

import pymysql


BASE_DIR = Path(__file__).resolve().parent
SQL_FILE = BASE_DIR / "database.sql"
DB_NAME = "cadena_restaurantes"


def split_sql(script):
    statements = []
    current = []
    in_string = False
    quote = ""
    prev = ""

    for char in script:
        current.append(char)
        if char in ("'", '"') and prev != "\\":
            if not in_string:
                in_string = True
                quote = char
            elif quote == char:
                in_string = False
                quote = ""
        if char == ";" and not in_string:
            statement = "".join(current).strip()
            if statement:
                statements.append(statement)
            current = []
        prev = char

    rest = "".join(current).strip()
    if rest:
        statements.append(rest)
    return statements


def clean_sql(script):
    return re.sub(r"^--.*$", "", script, flags=re.MULTILINE)


def database_exists(cursor):
    cursor.execute("SHOW DATABASES LIKE %s", (DB_NAME,))
    return cursor.fetchone() is not None


def table_exists(cursor, table_name):
    cursor.execute(f"USE {DB_NAME}")
    cursor.execute("SHOW TABLES LIKE %s", (table_name,))
    return cursor.fetchone() is not None


def column_exists(cursor, table_name, column_name):
    cursor.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = %s
          AND TABLE_NAME = %s
          AND COLUMN_NAME = %s
        """,
        (DB_NAME, table_name, column_name),
    )
    return cursor.fetchone()[0] > 0


def import_base_sql(cursor):
    if not SQL_FILE.exists():
        print("No existe database.sql")
        sys.exit(1)

    script = clean_sql(SQL_FILE.read_text(encoding="utf-8"))
    for statement in split_sql(script):
        cursor.execute(statement)


def ensure_extra_schema(cursor):
    cursor.execute(f"USE {DB_NAME}")
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS verificacion_correo (
            id_ver_pk INT PRIMARY KEY AUTO_INCREMENT,
            id_usu_fk INT NOT NULL,
            token VARCHAR(100) NOT NULL UNIQUE,
            verificado TINYINT(1) NOT NULL DEFAULT 0,
            fec_cre DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_usu_fk) REFERENCES usuario(id_usu_pk)
                ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB;
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS recuperacion_contrasena (
            id_rec_pk INT PRIMARY KEY AUTO_INCREMENT,
            id_usu_fk INT NOT NULL,
            token VARCHAR(100) NOT NULL UNIQUE,
            usado TINYINT(1) NOT NULL DEFAULT 0,
            fec_cre DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_usu_fk) REFERENCES usuario(id_usu_pk)
                ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB;
    """)
    if not column_exists(cursor, "usuario", "intentos_fallidos"):
        cursor.execute("""
            ALTER TABLE usuario
            ADD COLUMN intentos_fallidos INT NOT NULL DEFAULT 0;
        """)


def main():
    try:
        conn = pymysql.connect(
            host="127.0.0.1",
            user="root",
            password="",
            port=3306,
            charset="utf8mb4",
            autocommit=True,
        )
    except Exception as exc:
        print("No se pudo conectar a MySQL.")
        print("Abre XAMPP y prende MySQL antes de abrir este archivo.")
        print(exc)
        sys.exit(1)

    with conn.cursor() as cursor:
        if not database_exists(cursor):
            import_base_sql(cursor)
        elif not table_exists(cursor, "sede"):
            import_base_sql(cursor)
        else:
            cursor.execute(f"USE {DB_NAME}")

        ensure_extra_schema(cursor)

    conn.close()
    print("Base de datos MySQL lista sin borrar usuarios existentes.")


if __name__ == "__main__":
    main()
