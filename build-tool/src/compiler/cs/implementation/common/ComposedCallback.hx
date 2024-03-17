package compiler.cs.implementation.common;

typedef Callback<T>=(T)->Void;

class ComposedCallback<T> {
    var callbacks:Array<Callback<T>>;

    public function new() {
        callbacks = [];
    }

    public function add(callback:Callback<T>) {
        callbacks.push(callback);
    }

    public function remove(callback:Callback<T>) {
        callbacks.remove(callback);
    }

    public function call(value:T) {
        for (c in callbacks){
            c(value);
        }
    }

    public function callback(): Callback<T> {
        return this.call;
    }
}