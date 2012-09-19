var ResultSumView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ResultSumView = (function(_super) {

  __extends(ResultSumView, _super);

  function ResultSumView() {
    this.afterRender = __bind(this.afterRender, this);
    ResultSumView.__super__.constructor.apply(this, arguments);
  }

  ResultSumView.prototype.className = "info_box";

  ResultSumView.prototype.events = {
    'click .details': 'toggleDetails'
  };

  ResultSumView.prototype.toggleDetails = function() {
    return this.$el.find('.detail_box').toggle(250);
  };

  ResultSumView.prototype.initialize = function(options) {
    var prototype, subtest, _i, _len, _ref, _results;
    this.result = options.model;
    this.studentId = "";
    _ref = this.result.attributes.subtestData;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      subtest = _ref[_i];
      prototype = subtest.prototype;
      if (prototype === "id") {
        this.studentId = subtest.data.participant_id;
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ResultSumView.prototype.render = function() {
    var datum, html, i, _len, _ref;
    html = "<div>        " + this.studentId + "        " + (moment(new Date(this.result.get('timestamp'))).format('YYYY-MMM-DD HH:mm')) + "        (" + (moment(new Date(this.result.get('timestamp'))).fromNow()) + ")        <button class='details command'>details</button>      </div>      <div class='confirmation detail_box'>";
    _ref = this.result.get("subtestData");
    for (i = 0, _len = _ref.length; i < _len; i++) {
      datum = _ref[i];
      html += "<div><span id='" + this.cid + "_" + i + "'></span>" + datum.name + " - items " + datum.sum.total + "</div>";
    }
    html += "      </div>    ";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  ResultSumView.prototype.afterRender = function() {
    var datum, i, spark_id, _len, _ref;
    _ref = this.result.get("subtestData");
    for (i = 0, _len = _ref.length; i < _len; i++) {
      datum = _ref[i];
      spark_id = "#" + this.cid + "_" + i;
      this.$el.find(spark_id).sparkline([datum.sum.correct, datum.sum.incorrect, datum.sum.missing], {
        type: 'pie',
        width: '30',
        height: '30',
        sliceColors: ["#6f6", "#c66", "#ccc"]
      });
    }
    return null;
  };

  return ResultSumView;

})(Backbone.View);
