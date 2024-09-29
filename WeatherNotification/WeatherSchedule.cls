global class WeatherSchedule implements Schedulable {

   public static String CRON_EXP = '0 0 6 * * ?';

   global void execute(SchedulableContext sc) {
      WeatherBatch b = new WeatherBatch(); 
      Database.executeBatch(b);
   }
}
