import java.util.function.Function

enum class Three { ONE, TWO, THREE }

//sealed class Either<out A, out B> {
//    class Left<A>(internal val left: A) : Either<A, Nothing>()
//    class Right<B>(val right: B) : Either<Nothing, B>()
//}

sealed class Either<out L, out R> {
    data class Left<out L>(val left: L) : Either<L, Nothing>()
    data class Right<out R>(val right: R) : Either<Nothing, R>()
}


sealed class List<out A> {
    object Nil: List<Nothing>()
    data class Cons<out A>(val head: A, val tail: List<A>) : List<A>()
}

class Api {
    fun get(path: String,
            completion: (data: Any?, error: Error?) -> Unit) {
        // ...
    }
}


fun main(args: Array<String>) {
    println("Algebraic Data Types!")

    Pair(true, true)
    Pair(true, false)
    Pair(false, true)
    Pair(false, false)

    Pair<Unit, Boolean>(Unit, true)
    Pair(Unit, false)

    Pair<Unit, Unit>(Unit, Unit)

    Pair(Three.ONE, true)
    Pair(Three.ONE, false)
    Pair(Three.TWO, true)
    Pair(Three.TWO, false)
    Pair(Three.THREE, true)
    Pair(Three.THREE, false)

    Either.Left(true) as Either<Boolean, Boolean>
    Either.Left(false) as Either<Boolean, Boolean>
    Either.Right(true) as Either<Boolean, Boolean>
    Either.Right(false) as Either<Boolean, Boolean>

    val intOrString: Either<Int, String> = Either.Left(42)

    when(intOrString) {
        is Either.Left -> println(intOrString.left)
        is Either.Right -> println(intOrString.right)
    }


    val f: Function<Int, String> = Function({ _ -> "" })

    f.apply(2)

    val x: Int? = null

    if (x != null) {
        x.div(2)
    }
}
