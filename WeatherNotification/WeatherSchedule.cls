global class WeatherSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      WeatherBatch b = new WeatherBatch(); 
      Database.executeBatch(b);
   }
}
