var CheckDigit;

CheckDigit = (function() {
  CheckDigit.prototype.allowed = "ABCEFGHKMNPQRSTUVWXYZ".split("");

  CheckDigit.prototype.weights = [1, 2, 5, 11, 13];

  function CheckDigit(id) {
    if (id == null) {
      id = "";
    }
    this.set(id);
  }

  CheckDigit.prototype.set = function(id) {
    return this.id = id.toUpperCase();
  };

  CheckDigit.prototype.get = function(id) {
    var ch;
    if (id == null) {
      id = this.id;
    }
    if (!~((function() {
      var j, len, ref, results;
      ref = id.split("");
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        ch = ref[j];
        results.push(!~this.allowed.indexOf(ch));
      }
      return results;
    }).call(this)).indexOf(false)) {
      return null;
    }
    return id + this.getDigit(id);
  };

  CheckDigit.prototype.generate = function() {
    var i;
    return this.get(((function() {
      var j, len, ref, results;
      ref = this.weights;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        results.push(this.allowed[Math.floor(Math.random() * this.allowed.length)]);
      }
      return results;
    }).call(this)).join(""));
  };

  CheckDigit.prototype.isValid = function(id) {
    if (id == null) {
      id = this.id;
    }
    if (id.length !== 6) {
      return false;
    }
    return (this.get(id.slice(0, id.length - 1))) === id;
  };

  CheckDigit.prototype.isNotValid = function(id) {
    if (id == null) {
      id = this.id;
    }
    return !this.isValid(id);
  };

  CheckDigit.prototype.getErrors = function() {
    var ch, errors, i, j, k, len, len1, ref, result;
    errors = [];
    result = [];
    ref = (function() {
      var k, len, ref, results;
      ref = this.id.split("");
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        ch = ref[k];
        results.push(this.allowed.indexOf(ch));
      }
      return results;
    }).call(this);
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      ch = ref[i];
      if (ch === -1) {
        result.push(this.id[i]);
      }
    }
    if (result.length !== 0) {
      for (k = 0, len1 = result.length; k < len1; k++) {
        i = result[k];
        errors.push("Error: '" + result + "' is not a valid student id character. Only the following characters are allowed: " + this.allowed + "<br/>(this helps reduce errors while writing down student IDs)");
      }
    }
    if (this.id.length !== 6) {
      errors.push("Error: Identifier must be 6 letters");
    }
    if (errors.length === 0 && this.isNotValid()) {
      errors.push("Error: Invalid ID. Maybe it was written down incorrectly. Generate a new one then write down the old ID and the new one a piece of paper. Include both IDs in comments section at end of assessment.");
    }
    return errors;
  };

  CheckDigit.prototype.getDigit = function(id) {
    var ch, checkDigit_10, i, id_10, weight;
    if (id == null) {
      id = this.id;
    }
    id_10 = (function() {
      var j, len, ref, results;
      ref = id.split("");
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        ch = ref[j];
        results.push(this.allowed.indexOf(ch));
      }
      return results;
    }).call(this);
    checkDigit_10 = ((function() {
      var j, len, ref, results;
      ref = this.weights;
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        weight = ref[i];
        results.push(id_10[i] * weight);
      }
      return results;
    }).call(this)).reduce(function(x, y) {
      return x + y;
    });
    return this.allowed[checkDigit_10 % this.allowed.length];
  };

  return CheckDigit;

})();
