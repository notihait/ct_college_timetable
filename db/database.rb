def add_group_to_db(group_name):
    conn = sqlite3.connect('your_db.db')
    cursor = conn.cursor()
    cursor.execute("INSERT INTO groups (name) VALUES (?)", (group_name,))
    conn.commit()
    conn.close()

    