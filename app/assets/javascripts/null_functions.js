function isEmpty(val){
  return (val === undefined || val == null || val.length <= 0) ? true : false;
};

function ifNullToEmptyStr(val){
  return (val === undefined || val == null || val.length <= 0) ? "" : val;
};

