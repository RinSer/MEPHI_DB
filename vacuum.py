class Vaccum(object):

    def __init__(self, connection, schema):
        """
        Connect to Postgre database.
        """
        self.conn = connection
        self.schema = schema

    def get_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '%s'
            """ % self.schema

        cur = self.conn.cursor()
        cur.execute(query)

        for table in cur.fetchall():
            yield(table[0])

    def vaccum(self, table):
        """
        Run Vacuum on a given table.
        """

        query = "VACUUM VERBOSE ANALYZE %s" % table

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(0)

        cur = self.conn.cursor()
        cur.execute(query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return self.conn.notices
