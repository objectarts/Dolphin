(new-object net.webclient).DownloadFile('https://cdn.mysql.com//Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.40-win32.msi', 'mysqlodbc.msi')
msiexec /i mysqlodbc.msi /quiet /qn /norestart /log mysqlodbc.install.log