global class DailyWeatherSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      DailyWeatherBatch b = new DailyWeatherBatch(); 
      Database.executeBatch(b);
   }
}
