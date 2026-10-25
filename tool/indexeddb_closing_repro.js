(() => {
  const original = IDBDatabase.prototype.transaction;
  let injected = false;

  IDBDatabase.prototype.transaction = function (...args) {
    if (!injected && this.name === 'bible_path_web_v1') {
      injected = true;
      this.close();
      throw new DOMException(
        "Failed to execute 'transaction' on 'IDBDatabase': The database connection is closing.",
        'InvalidStateError',
      );
    }
    return original.apply(this, args);
  };
})();
