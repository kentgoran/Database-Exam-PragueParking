using System;
using System.Text;

namespace PragueParking_3._0
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.Unicode;
            Console.InputEncoding = Encoding.Unicode;
            //Here you can set the sql-server connection string
            //For testing-purposes. Would probably keep it in the backend instead of sending it through all the way normally
            string connectionString = @"Data Source=DESKTOP-21JF0EO\MSSQLSERVER01;Initial Catalog=PragueParking;Integrated Security=True";
            FrontEnd menu = new FrontEnd(connectionString);
            menu.MainMenu();
        }
    }
}
