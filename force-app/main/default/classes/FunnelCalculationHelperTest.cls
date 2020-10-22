@isTest  

public class FunnelCalculationHelperTest{

     static testmethod void testConvert() {  
     
        FunnelCalculationHelper fc = new FunnelCalculationHelper();
         
        
        FunnelCalculationHelper.convert(999999999,'$');
        FunnelCalculationHelper.convert(999999999,'');
        FunnelCalculationHelper.convert(-999999999,'$');
        FunnelCalculationHelper.convert(-999999999,'');
        FunnelCalculationHelper.convert(9999999,'$');
        FunnelCalculationHelper.convert(9999999,'');
        FunnelCalculationHelper.convert(-9999999,'$');
        FunnelCalculationHelper.convert(-9999999,'');
        FunnelCalculationHelper.convert(999999,'$');
        FunnelCalculationHelper.convert(999999,'');
        FunnelCalculationHelper.convert(-999999,'$');
        FunnelCalculationHelper.convert(-999999,'');
        FunnelCalculationHelper.convert(100,'$');
        FunnelCalculationHelper.convert(100,'');
        FunnelCalculationHelper.convert(-100,'$');
        FunnelCalculationHelper.convert(-100,'');
        
      /*  
        date d = date.newinstance(2018,5,15); 
        FunnelCalculationHelper.getQuarterEndDate(d);
        */
        string s = FunnelCalculationHelper.convert(100,'');
        system.assertEquals(s,'100');
        
     
     }

}