用协程做奇怪的事情
==================

“二十一天精通” 系列（ 预计耗时 **40min** ）


主题内容
--------

* 协程介绍

  * Lua 中的协程
  * 世界人民的实现

* 状态转移

  * 状态机的表达
  * 词法分析

* 异步编程

  * 老赵的 Wind.js
  * Greenlet/Gevent


协程介绍
--------

进程和线程
~~~~~~~~~~

进程
    占有操作系统 **资源** 的单元，一个运行的操作系统至少包含一个进程

线程
    占有处理机 **时间片** 的单元，一个运行的进程至少包含一个线程

.. image:: _media/htop.png

无论是进程还是线程，系统内核都知道它们的存在


对比协程
~~~~~~~~

协程仅仅是 **用户空间** 的一种调度实现

与进程&线程的不同之处
^^^^^^^^^^^^^^^^^^^^^

#. 操作系统内核不知道协程的存在

#. 协程不独享进程控制块和处理机时间片

与进程&线程的相同之处
^^^^^^^^^^^^^^^^^^^^^

#. 协程的状态存在挂起、唤醒、死亡

#. 协程和协程之前有控制权的释放和获取

非抢占 —— “协同式调度”
~~~~~~~~~~~~~~~~~~~~~~

所以不存在临界资源的安全问题

所以不存在复杂的调度管理问题

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: _media/philosopher.jpg

Lua 中的协程
~~~~~~~~~~~~

.. image:: _media/example.jpg

.. code-block:: lua

    #!/usr/bin/env lua5.2
    local generator;
    generator = coroutine.create(function ()
      for i=1,10 do
        print("LINE: ", i)
        coroutine.yield()
      end
    end)

.. code-block:: lua

    coroutine.resume(generator)
    coroutine.yield()

Lua 中的协程：DEMO
~~~~~~~~~~~~~~~~~~

.. image:: _media/one_to_ten.png

线性的执行过程可被挂起


世界人民的实现：Python —— 生成器
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: python

    def get_roles():
        yield "everyone"
        for role in user.roles:
            if role.is_enabled():
                yield role
        yield "#"

更多被用于“迭代器”

yield 执行时当前协程挂起

next() 唤醒挂起的协程继续执行到下一个挂起点

局限：挂起点是静态定义在函数代码中的

世界人民的实现：Python —— Greenlet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: python

    from time import sleep
    from greenlet import greenlet

    @greenlet
    def ping():
        while True:
            print("ping")
            sleep(1)
            pong.switch()

    @greenlet
    def pong():
        while True:
            print("pong")
            sleep(1)
            ping.switch()

    if __name__ == "__main__":
        ping.switch()

其他国家人民
~~~~~~~~~~~~

* Ruby & C#: Fiber (微线程、纤程)
* Erlang: Green Process
* Go: Goroutine
* Scala: Actor

表达状态转移
------------

状态机
~~~~~~

一个协程的挂起 + 另一个协程的唤醒 = 控制权转交

所以用协程可以非常简洁地表达有限状态自动机

（C 语言的 GOTO 也可以）

词法分析 (1)
~~~~~~~~~~~~

.. code-block:: lua

    -- 代码摘抄自：
    -- http://ravenw.com/blog/2011/09/01/coroutine-part-2-the-use-of-coroutines

    -- matching a string literal
    function prim(str)
        return function(S, pos)
            local len = string.len(str)
            if string.sub(S, pos, pos+len-1) == str then
                coroutine.yield(pos + len)
            end
        end
    end

    -- alternative patterns (disjunction)
    function alt(patt1, patt2)
        return function(S, pos)
            patt1(S, pos)
            patt2(S, pos)
        end
    end

词法分析 (2)
~~~~~~~~~~~~

.. code-block:: lua

    function match(S, patt)
        local len = string.len(S)
        local m = coroutine.wrap(function() patt(S, 1) end)
        for pos in m do
            if pos == len+1 then
                return true
            end
        end
        return false
    end

.. code-block:: lua

    local patt;

    -- 等同于正则表达式: (abc)|(de)
    patt = alt(prim("abc"), prim("de"))

    match("abc", patt) -- output: true
    match("de", patt) -- output: true
    match("abcde", patt) -- output: false

异步编程
--------

老赵的 Wind.js
~~~~~~~~~~~~~~

Greenlet/Gevent
~~~~~~~~~~~~~~~

面向关注面编程
--------------

引用资料
--------
