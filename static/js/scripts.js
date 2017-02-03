$(function(){
  'use strict';

  $('.btn-delete').click(function(){
    return confirm('Are you sure you want to delete?');
  })


  $('.datepicker').datepicker({
    format: 'dd/mm/yyyy'
    , endDate: "today"
    , autoclose: true
  });

  //===================Sales page=====================//
  var getNumbers = function(val){
    if (isNaN(parseFloat(val))) {
      return 0;
    } else {
      return parseFloat(val);
    }
  }

  var isValidNumber = function(val){
    if (val == '' || val == '0') {
      return true;
    }
    if (isNaN(val)) {
      return false;
    } else {
      return true;
    }
  }
  //=============================Fuels===========================//
  var validateFuelSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingRdg = getNumbers($('input.fuel_opening_reading' + itemIdAttr).val())
    , closingRdg = getNumbers($('input.fuel_closing_reading' + itemIdAttr).val())
    , testingRdg = getNumbers($('input.fuel_testing_reading' + itemIdAttr).val())
    , rate = getNumbers($('input.fuel_rate' + itemIdAttr).val())
    ;

    if (closingRdg < openingRdg) {
      alert('Closing reading has to be greater than opening reading');
      return false;
    }

    var sales = closingRdg - openingRdg;
    if (testingRdg > sales) {
      alert('Testing reading has to be less than sales');
      return false; 
    }

    if (rate <= 0) {
      alert('Rate has to be greater than zero');
      return false; 
    }
    return true;
  }

  var updateFuelSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingRdg = getNumbers($('input.fuel_opening_reading' + itemIdAttr).val())
    , closingRdg = getNumbers($('input.fuel_closing_reading' + itemIdAttr).val())
    , testinRdg = getNumbers($('input.fuel_testing_reading' + itemIdAttr).val())
    , salesEl = $('input.fuel_sales' + itemIdAttr)
    , sales = 0
    , rate = getNumbers($('input.fuel_rate' + itemIdAttr).val())
    , amountEl = $('input.fuel_amount' + itemIdAttr)
    , amount = 0
    , totalEl = $('input#fuel_total')
    , total = 0
    ;

    sales = closingRdg - openingRdg - testinRdg;
    if (sales < 0) { sales = 0; }
    
    amount = (sales * rate).toFixed(2);

    salesEl.val(sales);
    amountEl.val(amount);

    $('input.fuel_amount').each(function(){
      total += getNumbers($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.fuel_opening_reading, input.fuel_closing_reading, input.fuel_testing_reading, input.fuel_rate').focus(function(){
    $(this).select();
  })

  $('input.fuel_opening_reading, input.fuel_closing_reading, input.fuel_testing_reading, input.fuel_rate').on('input', function(e){
    e.preventDefault();
    if (!isValidNumber($(this).val())) {
      alert('Please enter valid number');
      var el = $(this);
      setTimeout(function(){
        el.val('0');
        el.focus();
      });
      return false;
    }
    return true;
  })

  $('input.fuel_opening_reading, input.fuel_closing_reading, input.fuel_testing_reading, input.fuel_rate').change(function(){
    var itemId = $(this).attr('data-item_id');
    var el = $(this);
    if (validateFuelSales(itemId)) {
      updateFuelSales(itemId);
    } else {
      setTimeout(function(){
        el.focus();
      });
    }
  })

  $('input.fuel_closing_reading').each(function(i, el){
    var itemId = $(el).attr('data-item_id');
    updateFuelSales(itemId);
  });

  $('form#fuel_sales').submit(function(e){
    var isValidated = true;
    $('input.fuel_closing_reading').each(function(i, el){
      var itemId = $(el).attr('data-item_id');
      isValidated = validateFuelSales(itemId);
      if (!isValidated) {
        setTimeout(function(){
          $(el).focus();
        });
      }
      return isValidated;
    });

    return isValidated;
  })

  //==============================Lubes=======================================//
  var validateLubeSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingRdg = getNumbers($('input.lube_opening_reading' + itemIdAttr).val())
    , addRdg = getNumbers($('input.lube_add_reading' + itemIdAttr).val())
    , closingRdg = getNumbers($('input.lube_closing_reading' + itemIdAttr).val())
    , testingRdg = getNumbers($('input.lube_testing_reading' + itemIdAttr).val())
    , rate = getNumbers($('input.lube_rate' + itemIdAttr).val())
    ;

    if ((openingRdg + addRdg) < closingRdg) {
      alert('Closing reading has to be less than opening reading');
      return false;
    }

    var sales = (openingRdg + addRdg) - closingRdg;
    if (testingRdg > sales) {
      alert('Gift item has to be less than sales');
      return false; 
    }

    if (rate <= 0) {
      alert('Rate has to be greater than zero');
      return false; 
    }
    return true;
  }

  var updateLubeSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingRdg = getNumbers($('input.lube_opening_reading' + itemIdAttr).val())
    , addRdg = getNumbers($('input.lube_add_reading' + itemIdAttr).val())
    , closingRdg = getNumbers($('input.lube_closing_reading' + itemIdAttr).val())
    , testinRdg = getNumbers($('input.lube_testing_reading' + itemIdAttr).val())
    , salesEl = $('input.lube_sales' + itemIdAttr)
    , sales = 0
    , rate = getNumbers($('input.lube_rate' + itemIdAttr).val())
    , amountEl = $('input.lube_amount' + itemIdAttr)
    , amount = 0
    , totalEl = $('input#lube_total')
    , total = 0
    ;

    sales = (openingRdg + addRdg) - closingRdg - testinRdg;
    if (sales < 0) { sales = 0; }
    
    amount = (sales * rate).toFixed(2);

    salesEl.val(sales);
    amountEl.val(amount);

    $('input.lube_amount').each(function(){
      total += getNumbers($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.lube_opening_reading, input.lube_add_reading, input.lube_closing_reading, input.lube_testing_reading, input.lube_rate').focus(function(){
    $(this).select();
  })

  $('input.lube_opening_reading, input.lube_add_reading, input.lube_closing_reading, input.lube_testing_reading, input.lube_rate').on('input', function(e){
    e.preventDefault();
    if (!isValidNumber($(this).val())) {
      alert('Please enter valid number');
      var el = $(this);
      setTimeout(function(){
        el.val('0');
        el.focus();
      });
      return false;
    }
    return true;
  })

  $('input.lube_opening_reading, input.lube_add_reading, input.lube_closing_reading, input.lube_testing_reading, input.lube_rate').change(function(){
    var itemId = $(this).attr('data-item_id');
    var el = $(this);
    if (validateLubeSales(itemId)) {
      updateLubeSales(itemId);
    } else {
      setTimeout(function(){
        el.focus();
      });
    }
  })

  $('input.lube_closing_reading').each(function(i, el){
    var itemId = $(el).attr('data-item_id');
    updateLubeSales(itemId);
  });

  $('form#lube_sales').submit(function(e){
    var isValidated = true;
    $('input.lube_closing_reading').each(function(i, el){
      var itemId = $(el).attr('data-item_id');
      isValidated = validateLubeSales(itemId);
      if (!isValidated) {
        setTimeout(function(){
          $(el).focus();
        });
      }
      return isValidated;
    });

    return isValidated;
  })

  //============================Expenses=======================================//
  var validateExpenseSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , amount = getNumbers($('input.expense_amount' + itemIdAttr).val())
    ;

    if (amount < 0) {
      alert('Amount has to be greater than or equal to zero');
      return false; 
    }
    return true;
  }

  var updateExpenseSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , amountEl = $('input.expense_amount' + itemIdAttr)
    , amount = getNumbers(amountEl.val())
    , totalEl = $('input#expense_total')
    , total = 0
    ;

    if (amount < 0) { amount = 0; }
    amountEl.val(amount);

    $('input.expense_amount').each(function(){
      total += getNumbers($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.expense_amount').focus(function(){
    $(this).select();
  })

  $('input.expense_amount').on('input', function(e){
    e.preventDefault();
    if (!isValidNumber($(this).val())) {
      alert('Please enter valid number');
      var el = $(this);
      setTimeout(function(){
        el.val('0');
        el.focus();
      });
      return false;
    }
    return true;
  })

  $('input.expense_amount').change(function(){
    var itemId = $(this).attr('data-item_id');
    var el = $(this);
    if (validateExpenseSales(itemId)) {
      updateExpenseSales(itemId);
    } else {
      setTimeout(function(){
        el.focus();
      });
    }
  })

  $('input.expense_amount').each(function(i, el){
    var itemId = $(el).attr('data-item_id');
    updateExpenseSales(itemId);
  });

  $('form#expense_sales').submit(function(e){
    var isValidated = true;
    $('input.expense_amount').each(function(i, el){
      var itemId = $(el).attr('data-item_id');
      isValidated = validateExpenseSales(itemId);
      if (!isValidated) {
        setTimeout(function(){
          $(el).focus();
        });
      }
      return isValidated;
    });

    return isValidated;
  })

});