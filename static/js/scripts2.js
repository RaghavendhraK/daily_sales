$(function(){
  'use strict';

  $('.datepicker').datepicker({
    format: 'dd/mm/yyyy'
    , endDate: "today"
    , autoclose: true
  });

  //===================Sales page=====================//
  var updateItemSales = function(itemId){
    var itemIdAttr = '[data-item_id="' + itemId + '"]'
    , openingStk = parseFloat($('input.opening_stock' + itemIdAttr).val())
    , closingStk = parseFloat($('input.closing_stock' + itemIdAttr).val())
    , salesEl = $('input.sales' + itemIdAttr)
    , sales = 0
    , rate = parseFloat($('input.rate' + itemIdAttr).val())
    , amountEl = $('input.amount' + itemIdAttr)
    , amount = 0
    , totalEl = $('input#total')
    , total = 0
    ;

    sales = openingStk - closingStk;
    amount = (sales * rate).toFixed(2);

    salesEl.val(sales);
    amountEl.val(amount);

    $('input.amount').each(function(){
      total += parseFloat($(this).val());
    });
    totalEl.val(total.toFixed(2));
  }

  $('input.closing_stock, input.rate').change(function(){
    var itemId = $(this).attr('data-item_id');
    updateItemSales(itemId);
  })

  $('input.closing_stock').change();

});