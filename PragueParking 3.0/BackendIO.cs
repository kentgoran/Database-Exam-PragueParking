using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace PragueParking_3._0
{
    class BackendIO
    {
        private readonly string connectionString;
        public BackendIO(string connectionString)
        {
            this.connectionString = connectionString;
        }
        /// <summary>
        /// Checks if a given regnr is present in the database. returns true if regnr is present, else false
        /// </summary>
        /// <param name="regNumber">The regnumber to check</param>
        /// <returns>a boolean, true if regnumber is present, else false</returns>
        public bool IsVehiclePresent(string regNumber)
        {
            string regCompare; //Used later on, initiated early so to not lose it when leaving the declaring-scope
            string sqlQuery = "SELECT Regnum FROM ParkedVehicle "
                            + "WHERE Regnum = @Regnumber;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnumber", regNumber);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    regCompare = reader[0].ToString();
                }
                catch
                {
                    return false;
                }
            }//if the value retrieved is the same as the value entered, the vehicle is present.
            if(regCompare.ToUpper() == regNumber.ToUpper())
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// Attempts to add a new vehicle to the database. Returns true if successfull, else false.
        /// </summary>
        /// <param name="regNum">The regnum of the vehicle</param>
        /// <param name="vehicleType">Type of the vehicle</param>
        /// <returns>True if successful, else false</returns>
        public bool AddVehicle(string regNumber, int vehicleType)
        {
            string queryString = "EXECUTE [InsertVehicle] @Regnum = @regNumber, @VehicleTypeID = @vehicleType;";
            int result = 0;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(queryString, connection);
                command.Parameters.AddWithValue("@regNumber", regNumber);
                command.Parameters.AddWithValue("@vehicleType", vehicleType);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch
                {
                    return false;
                }
            }//If atleast 1 row is affected (the number "result" gets, the vehicle has been added.
            return result > 0;
        }

        /// <summary>
        /// Attempts to move a vehicle to a new spot. Returns true if successful, else false.
        /// </summary>
        /// <param name="regNumber">The vehicle to move</param>
        /// <param name="newSpot">the spotnumber to move to.</param>
        /// <returns>true if successful, else false</returns>
        public bool MoveVehicle(string regNumber, int newSpot)
        {
            string sqlQuery = "EXECUTE [Move Vehicle] @Regnum = @regNumber, @ParkingSpot = @newSpot;";
            int result;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regNumber", regNumber);
                command.Parameters.AddWithValue("@newSpot", newSpot);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch
                {
                    return false;
                }
            }//If atleast 1 row is affected (the number "result" gets, the vehicle has been moved.
            return result > 0;
        }

        /// <summary>
        /// Removes a given vehicle, and puts it in the vehicleHistory. Requires regnr, and if PricePaid is null, calculates that automatically
        /// </summary>
        /// <param name="vehicleToRemove">The vehicle to remove. if PricePaid is null, calculate it automatically</param>
        /// <returns></returns>
        public bool RemoveVehicle(Vehicle vehicleToRemove)
        {
            string sqlQuery = "EXECUTE [Vehicle Leaving] @Regnum = @regNumber;";
            int result;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regNumber", vehicleToRemove.Regnr);
                if(vehicleToRemove.PricePaid != null)
                {
                    sqlQuery = "EXECUTE [Vehicle Leaving] @Regnum = @regNumber, @PaidMoney = @amountToPay;";
                    command.Parameters.AddWithValue("@amountToPay", vehicleToRemove.PricePaid);
                }
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch
                {
                    return false;
                }
            }//If atleast 1 row is affected (the number "result" gets, the vehicle has removed (sent to history).
            return result > 0;
        }

        /// <summary>
        /// Gets and returns a vehicle containing it's given arrivaltime, departuretime and the amount paid.
        /// </summary>
        /// <param name="regnr">The regnr to get data for</param>
        /// <returns>A vehicle-object containing arrivaltime, departuretime and the amount paid</returns>
        public Vehicle GetLeavingData(string regNumber)
        {
            Vehicle toReturn = new Vehicle(regNumber);
            //Query gets the latest vehicle-history-data for the given regnumber
            string sqlQuery = "SELECT TOP 1 InTime, OutTime, AmountPaid FROM VehicleHistory "
                            + "WHERE Regnum = @Regnumber "
                            + "ORDER BY OutTime DESC;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnumber", regNumber);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    
                    toReturn.ArrivalTime = DateTime.Parse(reader[0].ToString());
                    toReturn.DepartureTime = DateTime.Parse(reader[1].ToString());
                    toReturn.PricePaid = decimal.Parse(reader[2].ToString());
                }
                catch(Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return toReturn;
        }

        /// <summary>
        /// Finds and returns given vehicles parking spot number. Returns -1 if not found.
        /// </summary>
        /// <param name="regNumber">The regnumber to search with</param>
        /// <returns>the parking spot number, or -1 if not found.</returns>
        public int GetVehicleSpot(string regNumber)
        {
            int parkingSpotNumber = 0;
            string sqlQuery = "SELECT ps.ParkingSpotNumber FROM ParkingSpot ps "
                            + "JOIN ParkedVehicle pv ON ps.ParkingSpotID=pv.ParkingSpotID "
                            + "WHERE pv.Regnum = @Regnumber;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnumber", regNumber);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    parkingSpotNumber = (int)reader[0];
                }
                catch
                {
                    parkingSpotNumber = -1;
                }
            }
            return parkingSpotNumber;
        }

        /// <summary>
        /// Gets information on all vehicles currently parked. Returns a list of vehicles
        /// </summary>
        /// <returns>Returns a list of vehicles. Spotnumber, Regnum, VehicleType</returns>
        public List<Vehicle> GetAllParkedVehicles()
        {
            List<Vehicle> returnList = new List<Vehicle>();
            string sqlQuery = "SELECT ParkingSpotNumber, Regnum, VehicleTypeID FROM [Vehicles currently parked] "
                               + "ORDER BY ParkingSpotNumber;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        //[0] - SpotNumber [1] - Regnumber [2] - VehicleType
                        int spotNumber = int.Parse(reader[0].ToString());
                        string regNumber = reader[1].ToString();
                        int vehicleType = int.Parse(reader[2].ToString());
                        Vehicle toBeAdded = new Vehicle(regNumber, null, null, null, vehicleType, spotNumber);
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return returnList;
        }

        /// <summary>
        /// Gets and returns a list of vehicles, where time parked is atleast 
        /// as long as input parameter amountOfHours
        /// containing Parkingspot Regnumber VehicleType Hours parked
        /// </summary>
        /// <param name="amountOfHours">The amount of hours to check from</param>
        /// <returns>A list of vehicles. Parkingspot, Regnumber, VehicleType ,Hours parked</returns>
        public List<Vehicle> GetLongParkedVehicles(int amountOfHours)
        {
            List<Vehicle> returnList = new List<Vehicle>();
            string sqlQuery = "SELECT ParkingSpotNumber, Regnum, VehicleTypeID, [Hours parked] FROM [Vehicles currently parked] "
                            + "WHERE [Hours Parked] >= @AmountOfHours "
                            + "ORDER BY [Hours Parked] DESC;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@AmountOfHours", amountOfHours);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        //[0] - SpotNumber [1] - Regnumber [2] - VehicleType [3] - Hours parked
                        Vehicle toBeAdded = new Vehicle(reader[1].ToString());
                        toBeAdded.ParkingSpotNum = int.Parse(reader[0].ToString());
                        toBeAdded.VehicleType = int.Parse(reader[2].ToString());
                        toBeAdded.HoursParked = int.Parse(reader[3].ToString());
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return returnList;
        }

        /// <summary>
        /// Gets and returns a list of the vehicle types handled by the database.
        /// </summary>
        /// <returns>a List of strings, containing the different vehicle types and their associated id.</returns>
        public List<string> GetVehicleTypes()
        {
            List<string> returnList = new List<string>();
            string sqlQuery = "SELECT VehicleTypeID, TypeName FROM VehicleType;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        //[0] - VehicleTypeID, a number [1] - VehicleType Name (Car, Motorcycle etc)
                        string toBeAdded = $"{reader[0]}. {reader[1]}";
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return returnList;
        }

        /// <summary>
        /// Gets and returns a list of arrays of strings, containing [0]- Parking spot [1] Regnum
        /// </summary>
        /// <returns>A list of arrays of strings, containing [0]- Parking spot [1] Regnum</returns>
        public List<Vehicle> GetSingleParkedMotorcycles()
        {
            List<Vehicle> returnList = new List<Vehicle>();
            string sqlQuery = "SELECT ParkingSpotNumber, Regnum FROM [Single Parked Motorcycles] "
                            + "ORDER BY ParkingSpotNumber; ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Vehicle toBeAdded = new Vehicle(reader[1].ToString());
                        //[0] - SpotNumber [1] - Regnumber
                        toBeAdded.ParkingSpotNum =  int.Parse(reader[0].ToString());
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return returnList;
        }

        /// <summary>
        /// Gets and returns given date and income. [0] - Date, [1] - Income.
        /// </summary>
        /// <param name="startDate">Date to start the report</param>
        /// <param name="endDate">Date to end the report</param>
        /// <returns>A list of arrays of strings. Each array contains [0] - Date, [1] - Income</returns>
        public List<string[]> GenerateDailyIncomeReport(string startDate, string endDate)
        {
            List<string[]> toReturn = new List<string[]>();
            string sqlQuery = "SELECT [Date], [Income] FROM [Income per day] "
                            + "WHERE [Date] BETWEEN @startDate AND @endDate";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@startDate", startDate);
                command.Parameters.AddWithValue("@endDate", endDate);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        //[0] - Date, substring'ed to 10 characters, for YYYY-MM-DD
                        //[1] - Income for given [0]Date, substring'ed to it's length minus 2 last digits
                        //For a value like "12345.12". reader[1] is "12345.1234" raw.
                        string[] toAdd = { reader[0].ToString().Substring(0,10), 
                                           reader[1].ToString().Substring(0,reader[1].ToString().Length - 2) };
                        toReturn.Add(toAdd);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return toReturn;
        }

        /// <summary>
        /// Generates and returns a decimal, containing the average income per day for the interval given
        /// </summary>
        /// <param name="startingDate">starting date of the interval</param>
        /// <param name="endingDate">ending date of the interval</param>
        /// <returns>a decimal value containing daily sale average inside given interval</returns>
        public decimal GenerateAverageIncomeForInterval(string startingDate, string endingDate)
        {
            decimal valueToReturn = 0;
            string sqlQuery = "Average income given span";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                //Sets command-type to Stored Procedure, so to be able to get the return-value wanted.
                command.CommandType = CommandType.StoredProcedure;
                //Sets the return-value-parameter @AverageIncome, which then will hold 
                //the output-variable from the stored procedure
                SqlParameter returnValue = command.Parameters.Add("@AverageIncome", System.Data.SqlDbType.Money);
                returnValue.Direction = ParameterDirection.Output;
                command.Parameters.AddWithValue("@StartDate", startingDate);
                command.Parameters.AddWithValue("@EndDate", endingDate);
                try
                {
                    connection.Open();
                    command.ExecuteReader();
                    //Here, casts the returnvalue "@AverageIncome" as a decimal, and sets it to valueToReturn
                    valueToReturn = (decimal)returnValue.Value;

                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return valueToReturn;
        }

        /// <summary>
        /// Calls the database-SPROC which calculates a vehicles current cost.
        /// </summary>
        /// <param name="regNumber">the vehicle of which cost to calculate</param>
        /// <returns>a decimal containing the current cost</returns>
        public Vehicle GenerateSoFarForVehicle(string regNumber)
        {
            Vehicle vehicle = new Vehicle(regNumber);
            string sqlQuery = "Calculate Payment";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                //Sets command-type to Stored Procedure, so to be able to get the return-value wanted.
                command.CommandType = CommandType.StoredProcedure;
                //Sets the return-value-parameter @AmountToPay, which then will hold 
                //the output-variable from the stored procedure
                SqlParameter toPay = command.Parameters.Add("@AmountToPay", SqlDbType.Money);
                toPay.Direction = ParameterDirection.Output;
                command.Parameters.AddWithValue("@Regnum", regNumber);
                try
                {
                    connection.Open();
                    command.ExecuteReader();
                    //Here, casts the returnvalue "@AmountToPay" as a decimal, and sets it to valueToReturn
                    vehicle.PricePaid = (decimal)toPay.Value;

                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            //Another query for getting the arrival-time and current time from the database
            sqlQuery = "SELECT InTime, GETDATE() FROM ParkedVehicle "
                     + "WHERE Regnum = @Regnumber;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnumber", regNumber);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        vehicle.ArrivalTime = DateTime.Parse(reader[0].ToString());
                        vehicle.DepartureTime = DateTime.Parse(reader[1].ToString());
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return vehicle;
        }
    }
}
