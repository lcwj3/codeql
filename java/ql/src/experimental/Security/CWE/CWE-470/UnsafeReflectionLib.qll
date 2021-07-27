import java
import DataFlow
import semmle.code.java.Reflection
import semmle.code.java.dataflow.DataFlow3
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking2

/**
 * A call to a Java standard library method which constructs or returns a `Class<T>` from a `String`.
 * e.g `Class.forName(...)` or `ClassLoader.loadClass(...)`
 */
class ReflectiveClassIdentifierMethodAccessCall extends MethodAccess {
  ReflectiveClassIdentifierMethodAccessCall() {
    this instanceof ReflectiveClassIdentifierMethodAccess
  }
}

/**
 * Unsafe reflection sink.
 * e.g `Constructor.newInstance(...)` or `Method.invoke(...)` or `Class.newInstance()`.
 */
class UnsafeReflectionSink extends DataFlow::ExprNode {
  UnsafeReflectionSink() {
    exists(MethodAccess ma |
      (
        ma.getMethod().hasQualifiedName("java.lang.reflect", "Constructor<>", "newInstance")
        or
        ma.getMethod().hasQualifiedName("java.lang.reflect", "Method", "invoke")
      ) and
      ma.getQualifier() = this.asExpr() and
      exists(ReflectionArgsConfig rac | rac.hasFlowToExpr(ma.getAnArgument()))
    )
  }
}

/** Taint-tracking configuration tracing flow from remote sources to specifying the initialization parameters to the constructor or method. */
class ReflectionArgsConfig extends TaintTracking2::Configuration {
  ReflectionArgsConfig() { this = "ReflectionArgsConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) {
    exists(NewInstance ni | ni.getAnArgument() = sink.asExpr())
    or
    exists(MethodAccess ma |
      ma.getMethod().hasQualifiedName("java.lang.reflect", "Method", "invoke") and
      ma.getArgument(1) = sink.asExpr() and
      exists(ReflectionInvokeObjectConfig rioc | rioc.hasFlowToExpr(ma.getArgument(0)))
    )
  }
}

/** A data flow configuration tracing flow from the class object associated with the class to specifying the initialization parameters. */
class ReflectionInvokeObjectConfig extends DataFlow3::Configuration {
  ReflectionInvokeObjectConfig() { this = "ReflectionInvokeObjectConfig" }

  override predicate isSource(DataFlow::Node source) {
    exists(ReflectiveClassIdentifierMethodAccessCall rma | rma = source.asExpr())
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma |
      ma.getMethod().hasQualifiedName("java.lang.reflect", "Method", "invoke") and
      ma.getArgument(0) = sink.asExpr()
    )
  }

  override predicate isAdditionalFlowStep(Node pred, Node succ) {
    exists(NewInstance ni |
      ni.getQualifier() = pred.asExpr() and
      ni = succ.asExpr()
    )
    or
    exists(MethodAccess ma, Method m, int i, Expr arg |
      m = ma.getMethod() and arg = ma.getArgument(i)
    |
      m.getReturnType() instanceof TypeObject and
      arg.getType() instanceof TypeClass and
      arg = pred.asExpr() and
      ma = succ.asExpr()
    )
  }
}
