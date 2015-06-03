template <int T>
T main() {
    return (T) 0;
}

int f1() { return 0; }

int f2()
{ return 0; }

class B {}

class C : public B {
private:
    int method() {
        return 0;
    }
}
