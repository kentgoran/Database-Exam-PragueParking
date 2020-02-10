using System;
using System.Collections.Generic;
using System.Globalization;

namespace PragueParking_3._0
{
    class FrontEnd
    {
        private BackendIO databaseIO;
        public FrontEnd(string connectionString)
        {
            databaseIO = new BackendIO(connectionString);
        }

        /// <summary>
        /// Main menu, used to call all the other methods.
        /// </summary>
        public void MainMenu()
        {
            while (true)
            {
                Console.Clear();
                Console.WriteLine("\nPrague Parking, version 3.0");
                Console.WriteLine("***************************");
                Console.WriteLine("[1]    Add a vehicle");
                Console.WriteLine("[2]    Manually move a vehicle to another spot");
                Console.WriteLine("[3]    Remove vehicle");
                Console.WriteLine("[4]    Remove vehicle without charge");
                Console.WriteLine("[5]    Search for a vehicles parking spot");
                Console.WriteLine("[6]    Optimize motorcycle parking");
                Console.WriteLine("[7]    Economics menu");
                Console.WriteLine("[8]    Overview menu");
                Console.WriteLine("[9]    Exit");
                ConsoleKey input = Console.ReadKey().Key;
                switch (input)
                {
                    case ConsoleKey.D1:
                    case ConsoleKey.NumPad1:
                        AddVehicle();
                        break;
                    case ConsoleKey.D2:
                    case ConsoleKey.NumPad2:
                        MoveVehicle();
                        break;
                    case ConsoleKey.D3:
                    case ConsoleKey.NumPad3:
                        RemoveVehicle();
                        break;
                    case ConsoleKey.D4:
                    case ConsoleKey.NumPad4:
                        RemoveVehicleWithoutCharge();
                        break;
                    case ConsoleKey.D5:
                    case ConsoleKey.NumPad5:
                        SearchForVehicle();
                        break;
                    case ConsoleKey.D6:
                    case ConsoleKey.NumPad6:
                        OptimizeBikes();
                        break;
                    case ConsoleKey.D7:
                    case ConsoleKey.NumPad7:
                        EconomyMenu();
                        break;
                    case ConsoleKey.D8:
                    case ConsoleKey.NumPad8:
                        OverviewMenu();
                        break;
                    case ConsoleKey.D9:
                    case ConsoleKey.NumPad9:
                    case ConsoleKey.Escape:
                        ExitQuestion();
                        break;
                    default:
                        break;
                }
            }
        }

        /// <summary>
        /// Prompts user for regnr and vehicle type, then adds it to the parking lot database
        /// </summary>
        private void AddVehicle()
        {
            Console.Clear();
            Console.WriteLine("\nAdd a new vehicle");
            string regNumber = PromptUserRegnr();
            //If the regnumber is already in the database as an active park, the database won't take the new regnr.
            while (databaseIO.IsVehiclePresent(regNumber))
            {
                Console.WriteLine("Regnumber {0} is already parked here, enter another regnumber.", regNumber);
                regNumber = PromptUserRegnr();
            }
            int vehicleType = PromptUserVehicleType();
            bool success = databaseIO.AddVehicle(regNumber, vehicleType);
            if (success)
            {
                Console.WriteLine("Vehicle {0} added to the parking lot, park at spot {1}.", regNumber, databaseIO.GetVehicleSpot(regNumber));
            }
            else
            {
                Console.WriteLine("Couldn't add vehicle {0} to the parking lot. Please try again", regNumber);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Removes a vehicle, and shows the calculated price to be paid
        /// </summary>
        private void RemoveVehicle()
        {
            Console.Clear();
            Console.WriteLine("\nRemove a vehicle from the parking lot");
            string regNumber = PromptUserRegnr();
            while (!databaseIO.IsVehiclePresent(regNumber))
            {
                Console.WriteLine("Regnumber {0} is not found in the database.", regNumber);
                regNumber = PromptUserRegnr();
            }
            Vehicle toRemove = new Vehicle(regNumber);
            bool success = databaseIO.RemoveVehicle(toRemove);
            if (success)
            {
                Vehicle removedVehicle = databaseIO.GetLeavingData(regNumber);
                Console.WriteLine("Vehicle {0} removed from database.", regNumber);
                Console.WriteLine("Arrived at {0:g} \nDeparted at {1:g} \nA total fee of {2:0.00} Kč", removedVehicle.ArrivalTime, removedVehicle.DepartureTime, removedVehicle.PricePaid);
            }
            else
            {
                Console.WriteLine("Vehicle {0} could not be removed from the database.", regNumber);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Removes a given vehicle, and sets the AmountPaid to 0
        /// </summary>
        private void RemoveVehicleWithoutCharge()
        {
            Console.Clear();
            Console.WriteLine("Remove a vehicle from the parking lot without charging it");
            string regNumber = PromptUserRegnr();
            while (!databaseIO.IsVehiclePresent(regNumber))
            {
                Console.WriteLine("Regnumber {0} is not found in the database.", regNumber);
                regNumber = PromptUserRegnr();
            }
            Vehicle toRemove = new Vehicle(regNumber);
            //Setting pricePaid means that the price will NOT be automatically counted
            toRemove.PricePaid = 0;
            bool success = databaseIO.RemoveVehicle(toRemove);
            if (success)
            {
                Console.WriteLine("Vehicle {0} removed from database, no charge taken.", regNumber);
            }
            else
            {
                Console.WriteLine("Vehicle {0} could not be removed from the database.", regNumber);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Utilizes PromptUserRegnr and PromptUserParkingSpot to find a vehicle and put it at a new location, if possible.
        /// </summary>
        private void MoveVehicle()
        {
            Console.Clear();
            Console.WriteLine("\nMove vehicle to a new spot");
            string regNumber = PromptUserRegnr();
            while (!databaseIO.IsVehiclePresent(regNumber))
            {
                Console.WriteLine("Regnumber {0} is not found in the database.", regNumber);
                regNumber = PromptUserRegnr();
            }
            int parkingSpot = PromptUserParkingSpot();
            bool success = databaseIO.MoveVehicle(regNumber, parkingSpot);
            if (success)
            {
                Console.WriteLine("Vehicle {0} moved to spot no.{1}", regNumber, parkingSpot);
            }
            else
            {
                Console.WriteLine("Vehicle {0} could not be moved to spot no.{1}", regNumber, parkingSpot);
            }
            Console.ReadLine();
        }

        //Show parked hours
        /// <summary>
        /// Utilizes PromptUserRegnr and then tries to find that vehicles parking spot
        /// </summary>
        private void SearchForVehicle()
        {
            Console.Clear();
            Console.WriteLine("\nSearch for a vehicles parking spot");
            string regNumber = PromptUserRegnr();
            while (!databaseIO.IsVehiclePresent(regNumber))
            {
                Console.WriteLine("Regnumber {0} is not found in the database.", regNumber);
                regNumber = PromptUserRegnr();
            }
            int parkingSpot = databaseIO.GetVehicleSpot(regNumber);
            if(parkingSpot < 1)
            {
                Console.WriteLine("Vehicle {0}'s parking spot could not be found.", regNumber);
            }
            else
            {
                Vehicle parked = databaseIO.GenerateSoFarForVehicle(regNumber);
                TimeSpan timeBetween = (DateTime)parked.DepartureTime - (DateTime)parked.ArrivalTime;
                Console.WriteLine("Vehicle {0} is situated at spot no.{1}", regNumber, parkingSpot);
                Console.WriteLine("The vehicle has been parked for {0:0} hours and {1:0} minutes", timeBetween.TotalHours, timeBetween.Minutes);
                Console.WriteLine("Current cost is {0:0.00} Kč and counting.", parked.PricePaid);
            }
            Console.ReadLine();
        }
        
        /// <summary>
        /// Optimizes all the motorcycles so that there's a maximum of 1 lonely motorcycle in the parking lot.
        /// Also prints a work-order for moving the motorcycles in the parking lot
        /// </summary>
        private void OptimizeBikes()
        {
            Console.Clear();
            Console.WriteLine("\nOptimize motorcycle-parking at the parking lot");
            List<Vehicle> singleParked = databaseIO.GetSingleParkedMotorcycles();
            //If there's only 1 motorcycle, there can be no optimization.
            if(singleParked.Count < 2)
            {
                Console.WriteLine("Parking lot already optimized.");
            }
            else
            {
                while(singleParked.Count >= 2)
                {
                    //Takes the last part of the list, and adds it to the parkingspot of the first line.
                    //If that's a success, prints a workorder to physically move the motorcycle
                    //And then removes those 2 rows from the list, to continue the work
                    int spotFrom = (int)singleParked[singleParked.Count - 1].ParkingSpotNum;
                    int spotTo = (int)singleParked[0].ParkingSpotNum;
                    string regNum = singleParked[singleParked.Count - 1].Regnr;
                    bool success = databaseIO.MoveVehicle(regNum, spotTo);
                    if (success)
                    {
                        Console.WriteLine("Move {0} from spot {1} to spot {2}", regNum, spotFrom, spotTo);
                        singleParked.RemoveAt(singleParked.Count - 1);
                        singleParked.RemoveAt(0);
                    }
                }
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Prints the Economy-menu
        /// </summary>
        private void EconomyMenu()
        {
            bool stayInEconomy = true;
            while (stayInEconomy)
            {
                Console.Clear();
                Console.WriteLine("\nPrague Parking economic menu");
                Console.WriteLine("***************************");
                Console.WriteLine("[1]    Show income for given day");
                Console.WriteLine("[2]    Show income per day, for given interval");
                Console.WriteLine("[3]    Return to main menu");
                ConsoleKey input = Console.ReadKey().Key;
                switch (input)
                {
                    case ConsoleKey.D1:
                    case ConsoleKey.NumPad1:
                        IncomeSingleDay();
                        break;
                    case ConsoleKey.D2:
                    case ConsoleKey.NumPad2:
                        IncomeGivenInterval();
                        break;
                    case ConsoleKey.D3:
                    case ConsoleKey.NumPad3:
                        stayInEconomy = false;
                        break;
                    default:
                        break;
                }
            }
        }

        /// <summary>
        /// Gets the income for a single day
        /// </summary>
        private void IncomeSingleDay()
        {
            Console.Clear();
            Console.WriteLine("\nShow income for a given day");
            string date = PromptUserDate();
            List<string[]> givenIncome = databaseIO.GenerateDailyIncomeReport(date, date);
            if(givenIncome.Count > 0)
            {
                Console.WriteLine("On {0}, the income was {1} Kč.", givenIncome[0][0], givenIncome[0][1]);
            }
            //if there was nothing to return, there was no income on the given date
            else
            {
                Console.WriteLine("On {0}, there is no reported income.", date);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Gets the income for a given interval
        /// </summary>
        private void IncomeGivenInterval()
        {
            Console.Clear();
            Console.WriteLine("\nShow income for a given interval");
            string startDate = PromptUserDate("start");
            string endDate = PromptUserDate("end");
            List<string[]> givenIncome = databaseIO.GenerateDailyIncomeReport(startDate, endDate);
            decimal averageIncome = databaseIO.GenerateAverageIncomeForInterval(startDate, endDate);
            foreach (string[] gi in givenIncome)
            {
                Console.WriteLine("On {0}, the income was {1} Kč.", gi[0], gi[1]);
            }
            Console.WriteLine("The average income for the period {0}-{1} was: {2:0.00} Kč", startDate, endDate, averageIncome);
            Console.ReadLine();
        }
        /// <summary>
        /// Prompts user for a regnr. Checks so that it's 3-10 letters, and returns it.
        /// </summary>
        /// <returns>a string containing 3-10 characters, as a regnr</returns>
        private string PromptUserRegnr()
        {
            bool validInput = false;
            string output = "";
            do
            {
                Console.Write("Please enter the regnr: ");
                string input = Console.ReadLine();
                if (input.Length < 3 || input.Length > 10)
                {
                    Console.WriteLine("Regnr must be between 3 and 10 characters.");
                }
                char[] specialCharChecker = new char[] { ' ', '/', '[', '!', '@', '#', '$', '%', '&', '*', '(', ')', '_', '+', '=', '|', '<', '>', '?', '{', '}', '\'', '\'', '[', '\'', '\'', ']', '~', '-', ']' };
                if (input.IndexOfAny(specialCharChecker) != -1)
                {
                    Console.WriteLine(@"No special characters or whitespaces, like /[!@#$%&*()_+=|<>?{}\\[\\]~-]. Try again!");
                }
                else
                {
                    validInput = true;
                    output = input;
                }
            } while (!validInput);

            return output.ToUpper();
        }

        /// <summary>
        /// Prompts the user for the vehicle type, and checks so that it is valid before returning the value
        /// </summary>
        /// <returns>an integer containing an actual vehicletypeID</returns>
        private int PromptUserVehicleType()
        {
            int output = 0;
            List<string> vehicleTypes = databaseIO.GetVehicleTypes();
            int[] actualTypes = new int[vehicleTypes.Count];
            int i = 0;
            foreach(string vehicleType in vehicleTypes)
            {
                Console.WriteLine(vehicleType);
                //Stores the actual number of each of the vehicle types. to check for safe input
                actualTypes[i++] = int.Parse(vehicleType.Substring(0, 1));
            }
            bool validInput = false;
            do
            {
                Console.Write("Which of these vehicle-types is it? Answer with the number: ");
                string input = Console.ReadLine();
                bool validInt = int.TryParse(input, out output);
                if (!validInt)
                {
                    Console.WriteLine("Please, only a number.");
                }
                //If indexOf returns as -1, the value couldn't be found
                else if(Array.IndexOf(actualTypes, output) < 0)
                {
                    Console.WriteLine("Please only enter one of the numbers above.");
                }
                else
                {
                    validInput = true;
                }
            } while (!validInput);
            return output;
        }

        /// <summary>
        /// Prompts a user for a parking spot number
        /// </summary>
        /// <returns>a parking spot number</returns>
        private int PromptUserParkingSpot()
        {
            bool validInput = false;
            int output = 0;
            do
            {
                Console.Write("Please enter the parking spot number: ");
                string input = Console.ReadLine();
                bool isValidInt = int.TryParse(input, out output);
                if (!isValidInt)
                {
                    Console.WriteLine("Please only enter numbers.");
                }
                else if (output < 1 || output > 100)
                {
                    Console.WriteLine("Please choose a spot between 1-100.");
                }
                else
                {
                    validInput = true;
                }
            } while (!validInput);
            return output;
        }

        /// <summary>
        /// Prompts user for a date, and checks it so it's a correct YYYYMMDD.
        /// </summary>
        /// <param name="startOrEnd">optional parameter for "start"date, "end"date etc</param>
        /// <returns>a string containing a valid YYYYMMDD</returns>       
        private string PromptUserDate(string startOrEnd = "")
        {
            bool validInput = false;
            string output = "";
            do
            {
                Console.Write("Please enter the {0}date (YYYYMMDD): ", startOrEnd);
                string input = Console.ReadLine();
                //If this parses, it's a valid YYYYMMDD, hence it is valid to send to the database
                if (!DateTime.TryParseExact(input, "yyyyMMdd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime notUsed))
                {
                    Console.WriteLine("Not a valid input. Please ensure you are using YYYYMMDD.");
                }
                else
                {
                    validInput = true;
                    output = input;
                }
            } while (!validInput);

            return output; 
        }

        /// <summary>
        /// Prints the Overview-menu
        /// </summary>
        private void OverviewMenu()
        {
            bool stayInOverview = true;
            while (stayInOverview)
            {
                 Console.Clear();
                 Console.WriteLine("\nPrague Parking overview menu");
                 Console.WriteLine("***************************");
                 Console.WriteLine("[1]    Show all vehicles currently parked");
                 Console.WriteLine("[2]    Show all vehicles parked at least 48 hours");
                 Console.WriteLine("[3]    Return to main menu");
                 ConsoleKey input = Console.ReadKey().Key;
                 switch (input)
                 {
                     case ConsoleKey.D1:
                     case ConsoleKey.NumPad1:
                        PrintAllParkedVehicles();
                        break;
                     case ConsoleKey.D2:
                     case ConsoleKey.NumPad2:
                        PrintLongParkedVehicles();
                        break;
                     case ConsoleKey.D3:
                     case ConsoleKey.NumPad3:
                        stayInOverview = false;
                        break;
                     default:
                        break;
                 }
            }
        }

        /// <summary>
        /// Prints all vehicles currently parked
        /// </summary>
        private void PrintAllParkedVehicles()
        {
            //Use 2.0 printer?
            Console.Clear();
            Console.WriteLine("Currently parked vehicles:");
            int spot = 1;
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Car, yellow");
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine("Motorcycle, blue");
            Console.ResetColor();
            Console.WriteLine("__________________________________________________________________");
            for (int i = 0; i < 20; i++)//prints out all spots, with spot-number
            {
                Console.WriteLine("|            |            |            |            |            |");
                Console.WriteLine("|            |            |            |            |            |");
                Console.WriteLine("|            |            |            |            |            |");
                Console.WriteLine("|    {0:000}     |    {1:000}     |    {2:000}     |    " +
                    "{3:000}     |     {4:000}    |", spot++, spot++, spot++, spot++, spot++);
                Console.WriteLine("|____________|____________|____________|____________|____________|");
            }
            List<Vehicle> parkedVehicles = databaseIO.GetAllParkedVehicles();
            for(int i=0; i<parkedVehicles.Count; i++)
            {
                int currentSpot = (int)parkedVehicles[i].ParkingSpotNum;
                //Calculations for writing at the correct parking-spot
                int x = (((currentSpot - 1) % 5) * 13) + 1;   
                int y = ((((currentSpot - 1) / 5) + 1) * 5);
                //If the current vehicle is a motorcycle, and there is a vehicle coming after this one
                //Then check if the next vehicle is situated at the same spot. If so, print them both
                if (parkedVehicles[i].VehicleType == 1 && (i<parkedVehicles.Count - 1) && (parkedVehicles[i].ParkingSpotNum == parkedVehicles[i+1].ParkingSpotNum))
                {
                    Console.SetCursorPosition(x, y);
                    Console.ForegroundColor = ConsoleColor.Blue;
                    Console.Write(parkedVehicles[i].Regnr);
                    Console.SetCursorPosition(x, y + 1);
                    Console.Write(parkedVehicles[i+1].Regnr);
                    Console.ResetColor();
                    i++;
                }
                else
                {
                    if(parkedVehicles[i].VehicleType == 1)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.Write(parkedVehicles[i].Regnr);
                        Console.ResetColor();
                    }
                    else
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.Write(parkedVehicles[i].Regnr);
                        Console.ResetColor();
                    }
                }

            }
            Console.ReadLine();
        }

        /// <summary>
        /// Prints all vehicles parked longer than 48 hours. Can be changed in the method calling to another number.
        /// </summary>
        private void PrintLongParkedVehicles()
        {
            Console.Clear();
            Console.WriteLine("\nVehicles currently parked over 48 hours:");
            Console.WriteLine("******************************");
            List<Vehicle> parkedCars = databaseIO.GetLongParkedVehicles(48);
            foreach(Vehicle parkedCar in parkedCars)
            {
                Console.WriteLine("Hours: {0}\tSpot {1}\tReg: {2}\tType: {3}", parkedCar.HoursParked, 
                                                                               parkedCar.ParkingSpotNum, 
                                                                               parkedCar.Regnr, 
                                                                               parkedCar.VehicleType == 1 ? "Motorcycle" : "Car");
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Prompts user if he/she wants to terminate the program.
        /// Terminates if user says so.
        /// </summary>
        private void ExitQuestion()
        {
            Console.Clear();
            Console.WriteLine("Exit");
            Console.WriteLine();
            Console.Write("Are you sure you want to exit? Y/N");
            ConsoleKey exitYN = Console.ReadKey().Key;
            if (exitYN == ConsoleKey.Y || exitYN == ConsoleKey.Escape)
            {
                System.Environment.Exit(0);
            }
        }
    }
}
