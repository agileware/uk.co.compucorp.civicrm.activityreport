<h3>Activity Pivot Table</h3>

<div id="reportPivotTable">
  <div id="activity-report-preloader">
    Loading <span id="activity-report-loading-count">0</span> of <span id="activity-report-loading-total">0</span> Activities.
  </div>
</div>

{literal}
<script type="text/javascript">
    // Handle jQuery prop() method if it's not supported.
    (function($){
        if (typeof $.fn.prop !== 'function')
        $.fn.prop = function(name, value){
            if (typeof value === 'undefined') {
                return this.attr(name);
            } else {
                return this.attr(name, value);
            }
        };
    })(jQuery);
    CRM.$(function () {
        var data = [];
        var limit = 1000;

        function loadData(offset, limit, total, last) {
          CRM.$('span#activity-report-loading-count').text(offset);
          CRM.api3('ActivityReport', 'get', {
            "sequential": 1,
            "offset": offset,
            "limit": limit
          }).done(function(result) {
            data = data.concat(result['values']);
            if (last) {
              initPivotTable(data);
            } else {
              loadData(offset + limit, limit, total, ((offset + limit * 2) > total) ? true : false);
            }
          });
        }

        CRM.api3('Activity', 'getcount', {
          "sequential": 1,
          "is_current_revision": 1,
          "is_deleted": 0,
        }).done(function(result) {
          var total = parseInt(result.result, 10);
          CRM.$('span#activity-report-loading-total').text(total);
          loadData(0, limit, total, (limit > total) ? true : false);
        });

        function initPivotTable(data) {
          jQuery("#reportPivotTable").pivotUI(data, {
              rendererName: "Table",
              renderers: CRM.$.extend(
                  jQuery.pivotUtilities.renderers, 
                  jQuery.pivotUtilities.c3_renderers,
                  jQuery.pivotUtilities.export_renderers
              ),
              vals: ["Total"],
              rows: [],
              cols: [],
              aggregatorName: "Count",
              unusedAttrsVertical: false,
              rendererOptions: {
                  c3: {
                      size: {
                          width: parseInt(jQuery('#reportPivotTable').width() * 0.78, 10)
                      }
                  },
              },
              derivedAttributes: {
                  "Activity Date": jQuery.pivotUtilities.derivers.dateFormat("Activity Date Time", "%y-%m-%d"),
                  "Activity Start Date Months": jQuery.pivotUtilities.derivers.dateFormat("Activity Date Time", "%y-%m"),
                  "Activity is a test": function(row) {
                      if (parseInt(row["Activity is a test"], 10) === 0) {
                          return "No";
                      }
                      return "Yes";
                  },
                  "Activity Expire Date": function(row) {
                    if (!row["Expire Date"]) {
                      return "";
                    }
                    var expireDateParts = row["Expire Date"].split(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
                    return expireDateParts[3] + "-" + expireDateParts[1] + "-" + expireDateParts[2];
                  }
              },
              hiddenAttributes: ["Test", "Expire Date"]
          }, false);
        }
    });
</script>
{/literal}
