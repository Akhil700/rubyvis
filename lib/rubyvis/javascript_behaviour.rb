class TrueClass
  def to_i
    1
  end
end
class FalseClass
  def to_i
    0
  end
end


unless Object.public_method_defined? :instance_exec
  class Object
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block) # :nodoc:
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(mname="__instance_exec#{n}")
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
      ensure
        Thread.critical = old_critical
      end
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
  end

end
# Add javascript-like +apply+ and +call+ methods to Proc,
# called +js_apply+ and +js_call+, respectivly.

class Proc
  # Apply on javascript is very flexible. Can accept more or less
  # variables than explicitly defined parameters on lambda, so the method
  # adds or remove elements according to lambda arity
  #
  def js_apply(obj,args)
    arguments=args.dup
    # Modify numbers of args to works with arity
    min_args=self.arity>0 ? self.arity : (-self.arity)-1
    if args.size > min_args and self.arity>0
      arguments=arguments[0,self.arity]
    elsif args.size < min_args
      arguments+=[nil]*(min_args-args.size)
    end
    #puts "#{args}->#{arguments} (#{self.arity})"
    if self.arity==0
      obj.instance_eval(&self)
    else
      obj.instance_exec(*arguments,&self)
    end
	end
  # Same as js_apply, but using explicit arguments
	def js_call(obj,*args)
    js_apply(obj,args)
	end
end
