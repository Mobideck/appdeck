package com.mobideck.android.support;

import java.lang.reflect.Field;
import android.app.DatePickerDialog;
import android.content.Context;
import android.view.View;
import android.widget.DatePicker;

public class DatePickerDialogCustom extends DatePickerDialog {

	public DatePickerDialogCustom(Context context, int theme,
			OnDateSetListener callBack, int year, int monthOfYear,
			int dayOfMonth) {
		super(context, theme, callBack, year, monthOfYear, dayOfMonth);

	}
	
	public DatePickerDialogCustom(Context context, DatePickerDialog.OnDateSetListener callBack, int year, int monthOfYear, int dayOfMonth)
	{
		super(context, callBack, year, monthOfYear, dayOfMonth);		
	}

	protected boolean yearEnabled = true;
	protected boolean monthEnabled = true;
	protected boolean dayEnabled = true;
	
	public void setYearEnabled(boolean enabled)
	{
		yearEnabled = enabled;
		if (yearEnabled)
		{
			findAndShowField("mYearPicker");
			findAndShowField("mYearSpinner");
		} else {
			findAndHideField("mYearPicker");
			findAndHideField("mYearSpinner");			
		}
	}
	
	public void setMonthEnabled(boolean enabled)
	{
		monthEnabled = enabled;
		if (monthEnabled)
		{
			findAndShowField("mMonthPicker");
			findAndShowField("mMonthSpinner");
		} else {
			findAndHideField("mMonthPicker");
			findAndHideField("mMonthSpinner");			
		}
	}

	public void setDayEnabled(boolean enabled)
	{
		dayEnabled = enabled;
		if (dayEnabled)
		{
			findAndShowField("mDayPicker");
			findAndShowField("mDaySpinner");
		} else {
			findAndHideField("mDayPicker");
			findAndHideField("mDaySpinner");			
		}
	}
	
	
	public void onDateChanged (DatePicker view, int year, int month, int day)
	{
		//super.onDateChanged(view, year, month, day);
		/*DateFormat dateFormat = DateFormat.getDateTimeInstance();
		GregorianCalendar calendar = new GregorianCalendar(year, month, day);
		Date date = calendar.getTime();
		setTitle("Select:" + dateFormat.format(date));*/		
	}
	
	
    /** find a member field by given name and hide it */
    protected void findAndHideField(String name) {
        try {
        	Field mDatePickerField = DatePickerDialog.class.getDeclaredField("mDatePicker");
        	mDatePickerField.setAccessible(true);
        	DatePicker datepicker = (DatePicker) mDatePickerField.get(this);        	
            Field field = DatePicker.class.getDeclaredField(name);
            field.setAccessible(true);
            View fieldInstance = (View) field.get(datepicker);
            fieldInstance.setVisibility(View.GONE);
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }    
    
    
    /** find a member field by given name and show it */
    protected void findAndShowField(String name) {
        try {
        	Field mDatePickerField = DatePickerDialog.class.getDeclaredField("mDatePicker");
        	mDatePickerField.setAccessible(true);
        	DatePicker datepicker = (DatePicker) mDatePickerField.get(this);        	
            Field field = DatePicker.class.getDeclaredField(name);
            field.setAccessible(true);
            View fieldInstance = (View) field.get(datepicker);
            fieldInstance.setVisibility(View.VISIBLE);
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }  	
}
