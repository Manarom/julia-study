# REUSABILITY PATTERN
# * delegation pattern
# * The holy traits pattern
# * The parametric type pattern

# DELEGATION PATTERN

# The main idea of this pattern is to create a wrapper object 
# if we dont want to change externally provided functionality

# external API
mutable struct Account
    account_number::Int
    balance::Float64
    date_opened::Int
end
#-Accessors (getters)
account_number(a::Account)=a.account_number
balance(a::Account)=a.balance
#-Pvided functions
deposit!(a::Account,value::Float64)=begin 
    a.balance+=value
    return a
end
function transfer(from::Account,to::Account,ammount::Float64)
    if balance(from)>=ammount 
        deposit!(from,-ammount)
        deposit!(to,ammount)
    else
        error("Unable")
    end 
end


# We want to use external API in our new program
mutable struct AccountWrapper
    acc::Account
    interest_rate::Float64
    AccountWrapper(account_number,balance,date_opened,interest_rate)=
        new(Account(account_number,balance,date_opened),interest_rate)
end

# delegation or method forwarding:

account_number(a::AccountWrapper)=account_number(a.acc)
balance(a::AccountWrapper)=balance(a.acc)
transfer(from::AccountWrapper,to::AccountWrapper,ammount::Float64) = transfer(from.acc,to.acc,ammount)
interest_rate(a::AccountWrapper) = a.interest_rate
# etc
# additional capability:
function accrue_daily_interest!(sa::AccountWrapper)
    interest = balance(sa.acct) * interest_rate(sa) / 365
    deposit!(sa.acct, interest)
end

# there is a macros called @forward in Lazy.jl package to implement
# this pattern without writing method 
# forwarding by hands
import Lazy:@forward
@forward AccountWrapper.acc balance, account_number
@macroexpand @forward AccountWrapper.acc balance
balance(aw)