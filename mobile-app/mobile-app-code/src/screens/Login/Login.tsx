import { EyeIcon } from "lucide-react";
import React from "react";
import { Button } from "../../components/ui/button";
import { Card, CardContent } from "../../components/ui/card";
import { Checkbox } from "../../components/ui/checkbox";
import { Input } from "../../components/ui/input";

export const Login = (): JSX.Element => {
  return (
    <div className="bg-white flex flex-row justify-center w-full">
      <div className="bg-white w-[390px] h-[844px] relative">
        {/* Header Image */}
        <img
          className="absolute w-[390px] h-[273px] top-0 left-0 object-cover"
          alt="Rectangle"
          src="/rectangle-495.png"
        />

        {/* CompGenie Logo */}
        <div className="absolute w-[140px] h-[53px] top-[279px] left-[125px]">
          <div className="absolute w-[140px] h-[31px] top-[22px] left-0 [font-family:'Quicksand',Helvetica] font-bold text-transparent text-2xl tracking-[0] leading-[normal]">
            <span className="text-[#98c13f]">Comp</span>
            <span className="text-[#159148]">Genie</span>
          </div>
          <img
            className="absolute w-[33px] h-7 top-0 left-[51px] object-cover"
            alt="CompGenie Logo"
            src="/greengenielogocropped-1.png"
          />
        </div>

        {/* Welcome Text */}
        <div className="flex flex-col w-[278px] h-[73px] items-start gap-[4.88px] absolute top-[338px] left-[38px] rotate-[0.67deg]">
          <h1 className="relative w-fit mt-[-1.22px] [font-family:'Poppins',Helvetica] font-semibold text-black text-3xl tracking-[0] leading-[normal]">
            Welcome Back
          </h1>
          <p className="relative w-fit [font-family:'Poppins',Helvetica] font-normal text-black text-sm tracking-[0] leading-[normal]">
            Log in to your account
          </p>
        </div>

        {/* Login Form */}
        <div className="absolute w-[311px] h-[197px] top-[424px] left-8">
          <div className="flex flex-col w-[286px] h-[167px] items-start gap-[30.52px] absolute top-0 left-0 rotate-[0.14deg]">
            {/* Username Input */}
            <Card className="w-[288.79px] h-[68.37px] bg-neutral-100 rounded-[20.75px] border-none shadow-none">
              <CardContent className="p-0">
                <div className="flex flex-col w-full items-start relative top-2.5 left-[18px]">
                  <label className="relative mt-[-1.22px] [font-family:'Poppins',Helvetica] font-normal text-grey-500 text-[13.4px] tracking-[0] leading-[19.5px]">
                    User Name
                  </label>
                  <Input
                    className="border-none bg-transparent p-0 h-auto [font-family:'Poppins',Helvetica] font-normal text-grey-800 text-[19.5px] tracking-[0] leading-[29.3px]"
                    defaultValue="Afnan Jarabaa"
                  />
                </div>
              </CardContent>
            </Card>

            {/* Password Input */}
            <Card className="w-[286.73px] h-[68.37px] bg-neutral-100 rounded-[20.75px] border-none shadow-none">
              <CardContent className="p-0 relative">
                <div className="flex flex-col w-full items-start absolute top-2.5 left-3">
                  <label className="relative self-stretch mt-[-1.22px] [font-family:'Poppins',Helvetica] font-normal text-grey-500 text-[13.4px] tracking-[0] leading-[19.5px]">
                    Password
                  </label>
                  <Input
                    type="password"
                    className="border-none bg-transparent p-0 h-auto [font-family:'Roboto',Helvetica] text-[#494949] text-[19.5px] font-normal tracking-[0] leading-[29.3px]"
                    defaultValue="*************"
                  />
                </div>
                <div className="absolute w-[34px] h-[29px] top-5 right-4 flex items-center justify-center">
                  <EyeIcon className="w-6 h-6 text-gray-500" />
                </div>
              </CardContent>
            </Card>

            {/* Remember Me Checkbox */}
            <div className="flex items-center gap-[15px] relative">
              <Checkbox
                id="remember-me"
                className="w-5 h-5 rounded-[3.75px] border-[#0d986a] shadow-[0.94px_0.94px_3.75px_#00000040] bg-neutral-100"
              />
              <label
                htmlFor="remember-me"
                className="[font-family:'Roboto',Helvetica] font-bold text-[#013220] text-xl tracking-[0] leading-[normal]"
              >
                Remember Me
              </label>
            </div>
          </div>

          {/* Forget Password Link */}
          <div className="absolute w-[182px] top-[167px] left-[130px] rotate-[0.01deg] bg-[linear-gradient(180deg,rgba(1,50,32,1)_0%,rgba(1,103,52,1)_100%)] [-webkit-background-clip:text] bg-clip-text [-webkit-text-fill-color:transparent] [text-fill-color:transparent] [font-family:'Poppins',Helvetica] text-transparent text-[17.1px] font-normal tracking-[0] leading-[29.3px] whitespace-nowrap">
            Forget Password?
          </div>
        </div>

        {/* Login Button */}
        <Button className="flex w-[295px] h-[68px] items-center justify-center gap-[12.21px] px-[39.07px] py-[19.53px] absolute top-[669px] left-12 bg-[#0d986a] rounded-[19.53px] rotate-[-0.33deg] shadow-[0px_8.55px_29.3px_#4f756980] hover:bg-[#0b8a5f]">
          <span className="relative w-fit mt-[-1.07px] [font-family:'Poppins',Helvetica] font-medium text-white text-[19.5px] text-center tracking-[0] leading-[normal]">
            Log In
          </span>
        </Button>
      </div>
    </div>
  );
};
