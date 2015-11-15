$(function() {
  'use strict';

  //====================Trades list page================================/
  $('a#upload_trades').click(function(event) {
    event.preventDefault();
    $('input[name="trade"]').click();    
  });

  $('input[name="trade"]').change(function(event) {
    $('form#trade_form').submit();
  });

  $('select[name="ccy_pair"]').change(function(event) {
    window.location.href = window.location.pathname + "?ccy_pair=" + $(this).val()
  });

  $('a#delete_trades').click(function(event) {
    event.preventDefault();
    var isConfirmed = confirm('Are you sure?');
    if (isConfirmed) {
      $('form#delete_trades_form').submit();
    }
    return;
  });

  $('input#all_trades').change(function(){
    var isChecked = $(this).is(':checked')
    $('input[name="tradeIds"]').prop('checked', isChecked);
  });

  //====================Forecasts list page================================/
  $('a#upload_forecasts').click(function(event) {
    event.preventDefault();
    $('input[name="forecast"]').click();    
  });

  $('input[name="forecast"]').change(function(event) {
    $('form#forecast_form').submit();
  });

  $('a#delete_forecasts').click(function(event) {
    event.preventDefault();
    var isConfirmed = confirm('Are you sure?');
    if (isConfirmed) {
      $('form#delete_forecasts_form').submit();
    }
    return;
  });

  $('input#all_forecasts').change(function(){
    var isChecked = $(this).is(':checked')
    $('input[name="forecastIds"]').prop('checked', isChecked);
  });

  //====================Audit log page====================================/
  $('table#activity-logs a.accord').click(function(e){
    e.preventDefault();
    var content = $($(this).attr('href'));
    if(content.is(':hidden')){
      $('table#activity-logs div.accordion-contents').slideUp();
      content.slideDown();
    }else{
      content.slideUp();
    }
  });

  $('li.disabled a').click(function(e){
    e.preventDefault();
  });
  //====================General ==========================================/
  $('ul.dropdown-menu a').click(function(e){
    var id = $(this).parents('ul').attr('aria-labelledby');
    $('button#' + id).html($(this).text() + ' <span class="caret"></span>');
  })


  var rangePicker = $('.rangepicker');

  if (rangePicker.length > 0) {
    var fromDateEl = $('input[name="from"]')
    , toDateEl = $('input[name="to"]')
    , fromDate = fromDateEl.val()
    , toDate = toDateEl.val()
    , isSubmit = rangePicker.hasClass('submit')
    ;

    if (!fromDate || (fromDate && !fromDate.trim())) {
      fromDate = moment().subtract(29, 'days');
      toDate = moment();
    }

    var filterTrade = function(start, end) {
      var fromDate = start.format('MM-DD-YYYY')
      , toDate = end.format('MM-DD-YYYY')
      , ccyPair = $('input[name="ccy_pair"]').val()
      , url = window.location.pathname + "?from=" + fromDate + "&to=" + toDate
      ;
      
      if (ccyPair) {
        url += "&ccy_pair=" + ccyPair;
      }
      window.location = url;
    }

    var setSelectedDates = function(start, end) {
      var fromDate = start.format('MM-DD-YYYY')
      , toDate = end.format('MM-DD-YYYY')

      rangePicker.find('small').html('(' + fromDate + ' - ' + toDate + ')');
      fromDateEl.val(fromDate);
      toDateEl.val(toDate);
    }

    var clearSelectedDates = function() {
      rangePicker.find('small').html('(All)');
      fromDateEl.val('');
      toDateEl.val('');
    }

    rangePicker.daterangepicker({
      format: 'MM-DD-YYYY',
      startDate: fromDate,
      endDate: toDate,
      minDate: '01-01-2012',
      maxDate: '12-31-2015',
      dateLimit: { days: 60 },
      showDropdowns: true,
      showWeekNumbers: true,
      timePicker: false,
      timePickerIncrement: 1,
      timePicker12Hour: true,
      ranges: {
        'All': [0, 0],
        'Today': [moment(), moment()],
        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      },
      opens: 'left',
      buttonClasses: ['btn', 'btn-sm'],
      applyClass: 'btn-primary',
      cancelClass: 'btn-default',
      separator: ' to ',
      locale: {
        applyLabel: 'Apply',
        cancelLabel: 'Clear',
        fromLabel: 'From',
        toLabel: 'To',
        customRangeLabel: 'Custom',
        daysOfWeek: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr','Sa'],
        monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        firstDay: 1
      }
    }, function(start, end, label) {
      if (isSubmit) {
        return filterTrade(start, end);
      } else {
        return setSelectedDates(start, end);
      }
    });

    rangePicker.on('cancel.daterangepicker', function(){
      return clearSelectedDates();
    });
  }

});