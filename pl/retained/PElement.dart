class PElement extends PEventTarget{
  num _width, _height, _alpha;
  Size _lastDrawSize;
  bool clip = false;

  PElement(int this._width, int this._height, [bool enableCache = false])
  {
    if(enableCache){
      // TODO: init magic here
    }
  }

  Size get size(){
    return new Size(_width, _height);
  }

  AffineTransform getTransform() {
    var tx = new AffineTransform();
    /*
    if (this._transforms) {
      goog.array.forEach(this._transforms, function(t) {
        tx.concatenate(t);
      });
    }*/
    return tx;
  }

  bool draw(CanvasRenderingContext2D ctx){
    update();
    var dirty = (_lastDrawSize == null);
    _drawInternal(ctx);
    return dirty;
  }

  void update(){
    dispatchEvent('Update');
  }

  void _drawInternal(CanvasRenderingContext2D ctx){
    // until we ar rocking caching, just draw normal
    _drawNormal(ctx);
  }

  void _drawNormal(CanvasRenderingContext2D ctx){
    var tx = this.getTransform();
    if (this._isClipped(tx, ctx)) {
      return;
    }

    ctx.save();

    // Translate to the starting position
    gfx.transform(ctx, tx);

    // clip to the bounds of the object
    if (this.clip) {
      ctx.beginPath();
      ctx.rect(0, 0, _width, _height);
      ctx.clip();
    }

    this.drawCore(ctx);
    ctx.restore();
  }

  // abstract
  void drawOverride(CanvasRenderingContext2D ctx){
    // should throw here to inply subclass overriding
  }

  // protected
  void drawCore(CanvasRenderingContext2D ctx){
    if (_alpha != null) {
      ctx.globalAlpha = _alpha;
    }

    // call the abstract draw method
    drawOverride(ctx);
    _lastDrawSize = this.size;
  }

  bool _isClipped(AffineTransform tx, CanvasRenderingContext2D ctx){
    if(clip){
      // a lot more impl to do here...
    }
    return false;
  }

}