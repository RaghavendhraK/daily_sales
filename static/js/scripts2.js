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

  var updateFuelSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingRdg = getNumbers($('input.fuel_opening_reading' + itemIdAttr).val())
    , closingRdg = getNumbers($('input.fuel_closing_reading' + itemIdAttr).val())
    , salesEl = $('input.fuel_sales' + itemIdAttr)
    , sales = 0
    , rate = getNumbers($('input.fuel_rate' + itemIdAttr).val())
    , amountEl = $('input.fuel_amount' + itemIdAttr)
    , amount = 0
    , totalEl = $('input#fuel_total')
    , total = 0
    ;

    sales = closingRdg - openingRdg;
    amount = (sales * rate).toFixed(2);

    salesEl.val(sales);
    amountEl.val(amount);

    $('input.fuel_amount').each(function(){
      total += getNumbers($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.fuel_closing_reading, input.fuel_rate').change(function(){
    var itemId = $(this).attr('data-item_id');
    updateFuelSales(itemId);
  })

  $('input.fuel_closing_reading').change();

  var updateLubeSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingStk = getNumbers($('input.lube_opening_stock' + itemIdAttr).val())
    , closingStk = getNumbers($('input.lube_closing_stock' + itemIdAttr).val())
    , salesEl = $('input.lube_sales' + itemIdAttr)
    , sales = 0
    , rate = getNumbers($('input.lube_rate' + itemIdAttr).val())
    , amountEl = $('input.lube_amount' + itemIdAttr)
    , amount = 0
    , totalEl = $('input#lube_total')
    , total = 0
    ;

    sales = openingStk - closingStk;
    amount = (sales * rate).toFixed(2);

    salesEl.val(sales);
    amountEl.val(amount);

    $('input.lube_amount').each(function(){
      total += getNumbers($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.lube_closing_stock, input.lube_rate').change(function(){
    var itemId = $(this).attr('data-item_id');
    updateLubeSales(itemId);
  })

  $('input.lube_closing_stock').change();

});