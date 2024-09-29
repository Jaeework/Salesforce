@isTest
class WeatherScheduleTest {

    @isTest
    static void testSchedule() {
        
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('Weather Update Job', WeatherSchedule.CRON_EXP, new WeatherSchedule());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(WeatherSchedule.CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2024-09-30 06:00:00', ct.NextFireTime);

        Test.stopTest();

    }

}
