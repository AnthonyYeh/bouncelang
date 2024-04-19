const raylib = @import("raylib");
const std=@import("std");
inline fn scale(init:i32, ori:i32, new:i32)  i32 
{
    return @as(i32, @intFromFloat(@as(f32,@floatFromInt(init))/@as(f32,@floatFromInt(ori))*@as(f32,@floatFromInt(new))));
}

inline fn makeVec3(x:f32, y:f32, z:f32) raylib.Vector3
{
    return .{.x=x, .y=y, .z=z};
}
const sphere=struct{
    exists:bool=true,
    pos:raylib.Vector3,
    speed:raylib.Vector3,
    speed_val:f32,
    radius:f32,
    val:?i64,
    command:comm
};

const comm = enum{
        set,
        sset,
        ini,
        outi,
        inch,
        outch,
        add,
        sadd,
        sub,
        ssub,
        mul,
        smul,
        div,
        sdiv,
        mod,
        smod,
        gt,
        sgt,
        lt,
        slt,
        eq,
        seq,
        shr,
        sshr,
        shl,
        sshl,
        @"and",
        sand,
        @"or",
        sor,
        xor,
        sxor,
        ball

};

var allocator=std.heap.GeneralPurposeAllocator(.{}){};
var arallocator=std.heap.ArenaAllocator.init(allocator.allocator());
var sphspos=std.ArrayList(sphere).init(arallocator.allocator());
const init_wid:i32=800;
var init_hi:i32=800;

pub fn main() !void
{
    try parse_bn();
    try render();
}

pub fn render() !void {
    
    defer arallocator.deinit();
    const stdin=std.io.getStdIn();
    const stdout=std.io.getStdOut();    
    try stdout.writer().print("{d}\n", .{sphspos.items.len});
    

    
    
    raylib.SetTargetFPS(60);
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = false });
    raylib.InitWindow(init_wid, init_hi, "intepreting!");
    defer raylib.CloseWindow();
    
    var cube_mesh=raylib.GenMeshCube(50.0, 50.0, 50.0);
    defer raylib.UnloadMesh(cube_mesh);
    var cube=raylib.LoadModelFromMesh(cube_mesh);
    defer raylib.UnloadModel(cube);
    var cube_rot=makeVec3(0.0, 0.0, 0.0);
    var camera:raylib.Camera3D=.{.position=makeVec3(100.0,0.0,0.0), .target=makeVec3(0.0,0.0,0.0), .up=makeVec3(0.0, 0.0, 1.0), .fovy=200.0, .projection=.CAMERA_ORTHOGRAPHIC};
    
    

    
    while (!raylib.WindowShouldClose()) {
       
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        
        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);
        raylib.DrawText("intepreting!", 10, 40, 20, raylib.YELLOW);
        raylib.BeginMode3D(camera);
        
        
        cube_rot=cube_rot.add(makeVec3(0.01, 0.01, 0.01));
        cube.transform=raylib.MatrixRotateXYZ(cube_rot);
        raylib.DrawModel(cube, makeVec3(0.0, 0.0, 0.0), 1.0, raylib.GREEN);
        raylib.DrawModelWires(cube, makeVec3(0.0, 0.0, 0.0), 1.0, raylib.BLUE);
        
        for(sphspos.items, 0..sphspos.items.len)|*it, ind|
        label:{
            if(!it.exists) continue;
            //try stdout.writer().print("{any}\n", .{it});
            if(it.command==.ball)
            {   
                for(sphspos.items, 0..sphspos.items.len)|*it2, ind2|
                {
                    if(!it2.exists or ind==ind2) continue;
                    if(raylib.Vector3DistanceSqr(it.pos, it2.pos)<=it.radius+it2.radius)
                    {
                        it2.exists=false;
                        it.exists=false;
                        var radius13=it.radius*it.radius*it.radius;
                        var radius23=it2.radius*it2.radius*it2.radius;
                        var radiusum=radius13+radius23;
                        var pos=it.pos.scale(radius13).add(it2.pos.scale(radius23)).scale(1.0/radiusum);
                        var speed=it.speed.scale(radius13).add(it2.speed.scale(radius23)).scale(1.0/radiusum);
                        var val:?i64=null;
                        var command:comm=.ball;
                        switch (it2.command) {
                            .set=>
                            {
                                val=it2.val.?;
                            },
                            .sset=>
                            {
                                val=it.val.?;
                                command=.set;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .ini=>
                            {
                                var read_int_arr=std.BoundedArray(u8, 21){};
                                try stdin.reader().streamUntilDelimiter(read_int_arr.writer(),  '\r', read_int_arr.capacity());
                                val= try std.fmt.parseInt(i64, read_int_arr.slice(), 10);
                            },
                            .outi=>
                            {
                                try stdout.writer().print("{d}", .{it.val.?});
                                val=it.val.?;
                            },
                            .inch=>{
                                val=@as(i64, try stdin.reader().readByte());
                            },
                            .outch=>{
                                try stdout.writer().writeByte(@intCast(it.val.?));
                                val=it.val.?;
                            },
                            .add=>
                            {
                                val=(it.val.?)+it2.val.?;
                            },
                            .sadd=>
                            {
                                val=it.val.?;
                                command=.add;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .sub=>
                            {
                                val=it.val.?-it2.val.?;
                            },
                            .ssub=>
                            {
                                val=it.val.?;
                                command=.sub;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .mul=>
                            {
                                val=(it.val.?)*it2.val.?;
                            },
                            .smul=>
                            {
                                val=it.val.?;
                                command=.mul;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .div=>
                            {
                                val=@divFloor(it.val.?, it2.val.?);
                            },
                            .sdiv=>
                            {
                                val=it.val.?;
                                command=.div;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .mod=>
                            {
                                val=@mod(it.val.?, it2.val.?);
                            },
                            .smod=>
                            {
                                val=it.val.?;
                                command=.mod;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .gt=>
                            {
                                if(it.val.?>it2.val.?) {val=it.val.?;}
                                else {val=it2.val.?;speed=makeVec3(0.0, 0.0, -speed.length());}
                            },
                            .sgt=>
                            {
                                val=it.val.?;
                                command=.gt;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .lt=>
                            {
                                if(it.val.?<it2.val.?) {val=it.val.?;}
                                else {val=it2.val.?;speed=makeVec3(0.0, 0.0, -speed.length());}
                            },
                            .slt=>
                            {
                                val=it.val.?;
                                command=.lt;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .eq=>
                            {
                                if((it.val.?)==it2.val.?) {val=it.val.?;}
                                else {val=try std.math.absInt(it.val.?-it2.val.?);speed=makeVec3(0.0, 0.0, -speed.length());}
                            },
                            .seq=>
                            {
                                val=it.val.?;
                                command=.eq;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .shr=>
                            {
                                val=(it.val.?)>>@intCast(it2.val.?);
                            },
                            .sshr=>
                            {
                                val=it.val.?;
                                command=.shr;
                                speed=makeVec3(0.0, 0.0, 0.0);
                            },
                            .shl=>
                            {
                                val=(it.val.?)<<@intCast(it2.val.?);
                            },
                            .sshl=>
                            {
                                val=it.val.?;
                                command=.shl;
                                speed=makeVec3(0.0, 0.0, 0.0);   
                            },
                            .@"and"=>
                            {
                                val=(it.val.?)&it2.val.?;
                            },
                            .sand=>
                            {
                                val=(it.val.?);
                                command=.@"and";
                                speed=makeVec3(0.0, 0.0, 0.0);  
                            },
                            .@"or"=>
                            {
                                val=(it.val.?)|it2.val.?;
                            },
                            .sor=>
                            {
                                val=it.val.?;
                                command=.@"or";
                                speed=makeVec3(0.0, 0.0, 0.0); 
                            },
                            .xor=>
                            {
                                val=(it.val.?)^it2.val.?;
                            },
                            .sxor=>
                            {
                                val=(it.val.?);
                                command=.xor;
                                speed=makeVec3(0.0, 0.0, 0.0); 
                            },
                            .ball=>
                            {
                                val=@intFromFloat(radius13*@as(f32,@floatFromInt(it.val.?))+radius23*@as(f32,@floatFromInt(it2.val.?))/radiusum);
                            }
                        }
                        
                        try sphspos.append(.{.pos=pos,
                                            .speed=speed,
                                            .speed_val=speed.length(),
                                            .radius=std.math.pow(f32, radiusum, 1.0/3.0),
                                            .val=val,
                                            .command=command

                        });
                        break :label;
                    }
                }
            }
            var col=raylib.GetRayCollisionMesh(.{.position=it.pos, .direction=it.speed}, cube_mesh, cube.transform);
            if(col.hit and col.distance<it.speed_val)
            {        
                it.speed=it.speed.sub(col.normal.scale(2.0*it.speed.dot(col.normal)/(col.normal.length2())));
                it.pos=col.point.sub(it.speed.scale(col.distance/it.speed_val));
                  
            }
               
            if(it.pos.x <= -100.0 and it.speed.x < 0.0){it.speed.x=-it.speed.x;}
            if(it.pos.y <= -100.0 and it.speed.y < 0.0){it.speed.y=-it.speed.y;}
            if(it.pos.z <= -100.0 and it.speed.z < 0.0){it.speed.z=-it.speed.z;}
            if(it.pos.x >= 100.0 and it.speed.x > 0.0){it.speed.x=-it.speed.x;}
            if(it.pos.y >= 100.0 and it.speed.y > 0.0){it.speed.y=-it.speed.y;}
            if(it.pos.z >= 100.0 and it.speed.z > 0.0){it.speed.z=-it.speed.z;}   
            it.pos=it.pos.add(it.speed);
            raylib.DrawSphere(it.pos, it.radius, raylib.RED);
        }
        
        raylib.EndMode3D();
        
    }
}
pub fn parse_bn() !void
{
   // const stdin=std.io.getStdIn();
    const stdout=std.io.getStdOut();
    var argsIterator = try std.process.ArgIterator.initWithAllocator(arallocator.allocator());
    //defer argsIterator.deinit();
    _ = argsIterator.next();
    // Skip executable
    var file = try std.fs.cwd().openFile(argsIterator.next().?, .{});
    defer file.close();
    _=try stdout.writer().write("successfully opened file\n");
    
    
    var farr = try std.ArrayList(u8).initCapacity(arallocator.allocator(), (try file.stat()).size+3);
   var command:comm=undefined;
    try  file.reader().readAllArrayList(&farr, farr.capacity);
    _=try farr.writer().write("\r\n");
    _=try stdout.writer().write("successfully read file\n");
    var num:u64=0;    
    var init_ind:u64=0;
    var sparse:bool=true;
    var parsed:bool=false;
     var radius:f32=undefined;
      var xpos:f32=undefined;
      var ypos:f32=undefined;
      var zpos:f32=undefined;
      var val:?i64=null;
      var xv:f32=0.0;
      var yv:f32=0.0;
      var zv:f32=0.0;
      var line:u64=0;
    for(farr.items, 0..farr.items.len)|el, ind|
    {
     
      if((el==' ' or el=='\r') and !parsed)
      {
        switch(num){
        0=>
        {
            command=std.meta.stringToEnum(comm, farr.items[init_ind..ind]) orelse {try stdout.writer().print("{s} is not a valid command\n", .{farr.items[init_ind..ind]});unreachable;};
            parsed=true;
            num+=1;
            sparse=false;
            try stdout.writer().print("{s} ", .{farr.items[init_ind..ind]});
        },
        1=>
        {
            radius=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
            parsed=true;
            num+=1;
            sparse=false;
            try stdout.writer().print("{} ", .{radius});
        }, 
        2=>
        {
            xpos=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
            parsed=true;
            num+=1;
            sparse=false;
            try stdout.writer().print("{} ", .{xpos});
        },
        3=>
        {
            ypos=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
            parsed=true;
            num+=1;
            sparse=false;
            try stdout.writer().print("{} ", .{ypos});
        },
        4=>
        {
            zpos=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
            parsed=true;
            num+=1;
            sparse=false;
            try stdout.writer().print("{} ", .{zpos});
        },
        5=>{
            switch (command) {
                .set, .add, .sub, .mul, .div, .mod, .gt, .lt, .eq, .shr, .shl, .@"and", .@"or", .xor, .ball=>
                {
                    val=try std.fmt.parseInt(i64, farr.items[init_ind..ind], 10);
                    parsed=true;
                    num+=1;
                    sparse=false;
                    try stdout.writer().print("{d} ", .{val.?});
                },
                else=>{try stdout.writer().print("Invalid amount of arguments on line {d}", .{line+1});continue;}
            }
        },
        6=>
        {
            switch (command) {
                .ball=>
                {
                    xv=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
                    parsed=true;
                    num+=1;
                    sparse=false;
                    try stdout.writer().print("{} ", .{xv});
                },
                else=>{try stdout.writer().print("Invalid amount of arguments on line {d}", .{line+1});continue;}
            }

        },
        7=>
        {
            switch (command) {
                .ball=>
                {
                    yv=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
                    parsed=true;
                    num+=1;
                    sparse=false;
                    try stdout.writer().print("{} ", .{yv});
                },
                else=>{try stdout.writer().print("Invalid amount of arguments on line {d}", .{line+1});continue;}
            }
        },
        8=>
        {
            switch (command) {
                .ball=>
                {
                    zv=try std.fmt.parseFloat(f32, farr.items[init_ind..ind]);
                    parsed=true;
                    num+=1;
                    sparse=false;
                    try stdout.writer().print("{} ", .{zv});
                },
                else=>{try stdout.writer().print("Invalid amount of arguments on line {d}\n", .{line+1});continue;}
            }
        },
        else=>{try stdout.writer().print("Invalid amount of arguments on line {d}\n", .{line+1});continue;}
        
        }
        
      }
      if(el=='\n')
      {
        const a=.{
            .pos=makeVec3(xpos, ypos, zpos),
            .speed=makeVec3(xv, yv, zv),
            .speed_val=std.math.pow(f32, xv*xv+yv*yv+zv*zv, 1.0/3.0),
            .radius=radius,
            .val=val,
            .command=command
        };
        try sphspos.append(a);
        try stdout.writer().print("{any}", .{a});
        try stdout.writer().writeByte('\n');
        num=0;
        line+=1;
        val=null;
        xv=0.0;
        yv=0.0;
        zv=0.0;
      }
      if((('a'<=el and el<='z') or ('0'<=el and el<='9') or el=='.' ) and !sparse)
      {
        init_ind=ind;
        sparse=true;
        parsed=false;
      }  
    }


    
}